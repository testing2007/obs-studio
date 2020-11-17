1: 视频数据相关结构体

```c
struct video_frame {
	uint8_t *data[MAX_AV_PLANES];
	uint32_t linesize[MAX_AV_PLANES];
};

struct video_data {
	uint8_t *data[MAX_AV_PLANES];
	uint32_t linesize[MAX_AV_PLANES];
	uint64_t timestamp;
};

struct cached_frame_info {
	struct video_data frame;
	int skipped;
	int count;
};

struct cached_frame_info *cfi;
struct video_frame *frame;
memcpy(frame, &cfi->frame, sizeof(*frame)); //## 注意：这里是将 video_data 数据拷贝到 video_frame 中， video_data 相比多一个 timestamp. 所以大小取frame

struct video_frame {
	uint8_t *data[MAX_AV_PLANES];
	uint32_t linesize[MAX_AV_PLANES];
};
```

2: 初始化视频数据相关文件 及 方法
libobs/media-io/video-io.c
libobs/media-io/video-frame.c

```c
//video-io.c
static inline void init_cache(struct video_output *video)
{
	if (video->info.cache_size > MAX_CACHE_SIZE)
		video->info.cache_size = MAX_CACHE_SIZE;
    //## 一共有最大 MAX_CACHE_SIZE(16)个视频帧缓存, 会根据颜色分配数据存储
	for (size_t i = 0; i < video->info.cache_size; i++) {
		struct video_frame *frame;
		frame = (struct video_frame *)&video->cache[i];
        
        //libobs/media-io/video-frame.c
		video_frame_init(frame, video->info.format, video->info.width,
				 video->info.height);
	}

	video->available_frames = video->info.cache_size;
}

int video_output_open(video_t **video, struct video_output_info *info)
{
	struct video_output *out;
	pthread_mutexattr_t attr;

	if (!valid_video_params(info))
		return VIDEO_OUTPUT_INVALIDPARAM;

	out = bzalloc(sizeof(struct video_output));
	if (!out)
		goto fail;

	memcpy(&out->info, info, sizeof(struct video_output_info));
	out->frame_time =
		util_mul_div64(1000000000ULL, info->fps_den, info->fps_num);
	out->initialized = false;

	if (pthread_mutexattr_init(&attr) != 0)
		goto fail;
	if (pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE) != 0)
		goto fail;
	if (pthread_mutex_init(&out->data_mutex, &attr) != 0)
		goto fail;
	if (pthread_mutex_init(&out->input_mutex, &attr) != 0)
		goto fail;
	if (os_sem_init(&out->update_semaphore, 0) != 0)
		goto fail;
	if (pthread_create(&out->thread, NULL, video_thread, out) != 0)
		goto fail;

	init_cache(out);//## 初始化视频帧缓存

	out->initialized = true;
	*video = out;
	return VIDEO_OUTPUT_SUCCESS;

fail:
	video_output_close(out);
	return VIDEO_OUTPUT_FAIL;
}

/* messy code alarm */
void video_frame_init(struct video_frame *frame, enum video_format format,
		      uint32_t width, uint32_t height)
{
	size_t size;
	size_t offsets[MAX_AV_PLANES];
	int alignment = base_get_alignment();

	if (!frame)
		return;

	memset(frame, 0, sizeof(struct video_frame));
	memset(offsets, 0, sizeof(offsets));

	switch (format) {
	case VIDEO_FORMAT_NONE:
		return;

	case VIDEO_FORMAT_I420:
		//***省略

		break;

	case VIDEO_FORMAT_NV12://视频输出格式
		//***省略
		size = width * height;
		ALIGN_SIZE(size, alignment);
		offsets[0] = size;
		size += (width / 2) * (height / 2) * 2;
		ALIGN_SIZE(size, alignment);
		frame->data[0] = bmalloc(size);
		frame->data[1] = (uint8_t *)frame->data[0] + offsets[0];
		frame->linesize[0] = width;
		frame->linesize[1] = width;
		break;

	case VIDEO_FORMAT_Y800:
		//***省略

		break;

	case VIDEO_FORMAT_YVYU:
	case VIDEO_FORMAT_YUY2:
	case VIDEO_FORMAT_UYVY:
		//***省略
		break;

	case VIDEO_FORMAT_RGBA:
	case VIDEO_FORMAT_BGRA:
	case VIDEO_FORMAT_BGRX:
	case VIDEO_FORMAT_AYUV:
		//***省略
		break;

	case VIDEO_FORMAT_I444:
		//***省略
		break;

	case VIDEO_FORMAT_BGR3:
		//***省略
		break;

	case VIDEO_FORMAT_I422:
		//***省略

		break;

	case VIDEO_FORMAT_I40A:
		//***省略

		break;

	case VIDEO_FORMAT_I42A:
		//***省略

		break;

	case VIDEO_FORMAT_YUVA:
		//***省略
		break;
	}
}
```

3: obs_graphics_thread 渲染线程与 video_thread （libobs/medio-io/video-io.c）线程关系：
```c
//obs_graphics_thread 渲染线程
void *obs_graphics_thread(void *param){
	***
	//将采集输入数据根据输出定义的颜色格式将数据输出（比如转换成YU格式）,输出的数据可以通过全局变量obs->video->video->cache[index]->frame中的data 及 linesize
	//一旦数据输出， 就会调用 video_out_unlock_frame(video->video), 发送信号量 os_sem_post(video->update_semaphore); 给 video_thread
	//注意：如果没有输出(比如：没有录像， raw_active 为false, output_frame就相当于一个空操作)
	output_frame(raw_active, gpu_active); 

	***



}

static inline void output_video_data(struct obs_core_video *video,
				     struct video_data *input_frame, int count)
{
    const struct video_output_info *info;
	struct video_frame output_frame;
	bool locked;

	info = video_output_get_info(video->video);

	locked = video_output_lock_frame(video->video, &output_frame, count,
					 input_frame->timestamp);
	if (locked) {
		if (video->gpu_conversion) {
            //## 输入的数据拷贝到输出缓冲区中去， 也就是视频初始化定义的输出 cache->data 及 cache->linesize 中
			set_gpu_converted_data(video, &output_frame,
					       input_frame, info);
		} else {
			copy_rgbx_frame(&output_frame, input_frame, info);
		}

		video_output_unlock_frame(video->video);
	}
}
```

```c
//video_thread (libobs/media-io/video-io.c)
static void *video_thread(void *param)
{
	//参数就是视频输出数据
	struct video_output *video = param;

	os_set_thread_name("video-io: video thread");

	const char *video_thread_name =
		profile_store_name(obs_get_profiler_name_store(),
				   "video_thread(%s)", video->info.name);

	//一旦有输出数据，就会被激活
	while (os_sem_wait(video->update_semaphore) == 0) {
		if (video->stop)
			break;

		profile_start(video_thread_name);
		//video_output_cur_frame 会根据定义的输出信息 及 获取到的数据信息，找到对应的编码器， 对数据进行编码，注意这里面video->cache已经是渲染线程转变成了YUV后的格式
		//调用完这个函数，会根据对应的编码器，对类似YUV再进行进行编码
		while (!video->stop && !video_output_cur_frame(video)) {
			os_atomic_inc_long(&video->total_frames);
		}

		os_atomic_inc_long(&video->total_frames);
		profile_end(video_thread_name);

		profile_reenable_thread();
	}

	return NULL;
}

static inline bool video_output_cur_frame(struct video_output *video)
{
	struct cached_frame_info *frame_info;
	bool complete;
	bool skipped;

	/* -------------------------------- */

	pthread_mutex_lock(&video->data_mutex);

	frame_info = &video->cache[video->first_added];

	pthread_mutex_unlock(&video->data_mutex);

	/* -------------------------------- */

	pthread_mutex_lock(&video->input_mutex);

	for (size_t i = 0; i < video->inputs.num; i++) {
		struct video_input *input = video->inputs.array + i;
		struct video_data frame = frame_info->frame;

		if (scale_video_output(input, &frame))
			input->callback(input->param, &frame);//## 调用 obs-encoder.c::receive_video 函数
	}

	pthread_mutex_unlock(&video->input_mutex);

	/* -------------------------------- */

	pthread_mutex_lock(&video->data_mutex);

	frame_info->frame.timestamp += video->frame_time;
	complete = --frame_info->count == 0;
	skipped = frame_info->skipped > 0;

	if (complete) {
		if (++video->first_added == video->info.cache_size)
			video->first_added = 0;

		if (++video->available_frames == video->info.cache_size)
			video->last_added = video->first_added;
	} else if (skipped) {
		--frame_info->skipped;
		os_atomic_inc_long(&video->skipped_frames);
	}

	pthread_mutex_unlock(&video->data_mutex);

	/* -------------------------------- */

	return complete;
}

//libobs/libobs/obs-encoder.c
static void receive_video(void *param, struct video_data *frame)
{
	profile_start(receive_video_name);

	struct obs_encoder *encoder = param;
	struct obs_encoder *pair = encoder->paired_encoder;
	struct encoder_frame enc_frame;

	if (!encoder->first_received && pair) {
		if (!pair->first_received ||
		    pair->first_raw_ts > frame->timestamp) {
			goto wait_for_audio;
		}
	}

	if (video_pause_check(&encoder->pause, frame->timestamp))
		goto wait_for_audio;

	memset(&enc_frame, 0, sizeof(struct encoder_frame));

	for (size_t i = 0; i < MAX_AV_PLANES; i++) {
		enc_frame.data[i] = frame->data[i];
		enc_frame.linesize[i] = frame->linesize[i];
	}

	if (!encoder->start_ts)
		encoder->start_ts = frame->timestamp;

	enc_frame.frames = 1;
	enc_frame.pts = encoder->cur_pts;

	if (do_encode(encoder, &enc_frame)) //当前文件 do_encode 函数
		encoder->cur_pts += encoder->timebase_num;

wait_for_audio:
	profile_end(receive_video_name);
}

bool do_encode(struct obs_encoder *encoder, struct encoder_frame *frame)
{
	profile_start(do_encode_name);
	if (!encoder->profile_encoder_encode_name)
		encoder->profile_encoder_encode_name =
			profile_store_name(obs_get_profiler_name_store(),
					   "encode(%s)", encoder->context.name);

	struct encoder_packet pkt = {0};
	bool received = false;
	bool success;

	pkt.timebase_num = encoder->timebase_num;
	pkt.timebase_den = encoder->timebase_den;
	pkt.encoder = encoder;

	profile_start(encoder->profile_encoder_encode_name);
	success = encoder->info.encode(encoder->context.data, frame, &pkt,
				       &received);//## 最终会查询到对应的编码器， 最终编码的数据会存放在 pkt 变量中，比如找到类似 plugin/obs-x264/obs-x264.c::obs_x264_encode 函数
	profile_end(encoder->profile_encoder_encode_name);
	send_off_encoder_packet(encoder, success, received, &pkt);

	profile_end(do_encode_name);

	return success;
}
```




















#include "test.h"

#include <string>
#include <sstream>
#include <iostream>
using namespace std;

static const int base_width = 1920; //800;
static const int base_height = 1080;  //600;

static const int cx = 1280; //800;
static const int cy = 720;  //600;

static void initOBS()
{
	if (!obs_startup("zh-CN", nullptr, nullptr))
		throw "Couldn't create OBS";

	struct obs_video_info ovi;
    ovi.adapter = 0;
    ovi.fps_num = 60;
    ovi.fps_den = 1;
    ovi.graphics_module = DL_OPENGL;
    ovi.base_width = base_width;
    ovi.base_height = base_height;
    ovi.output_width = cx;
    ovi.output_height = cy;
    
    //视频输出格式
    //VIDEO_FORMAT_NV12:窗口部分显示，其余黑背景色；
    //VIDEO_FORMAT_RGBA:可以将显示窗口铺满
    ovi.output_format = VIDEO_FORMAT_RGBA;
    
    ovi.gpu_conversion = true;
    ovi.colorspace = VIDEO_CS_709;
    ovi.range = VIDEO_RANGE_PARTIAL;
    ovi.scale_type = OBS_SCALE_BICUBIC;
    
	if (obs_reset_video(&ovi) != 0)
		throw "Couldn't initialize video";
    
    struct obs_audio_info ai;
    ai.samples_per_sec = 48000;
    ai.speakers = SPEAKERS_STEREO;
    if (obs_reset_audio(&ai) == 0)
        throw "Couldn't initialize audio";
}

static DisplayContext CreateDisplay(id view)
{
	gs_init_data info = {};
    info.cx = cx;
    info.cy = cy;
	info.format = GS_BGRA;
	info.zsformat = GS_ZS_NONE;
	info.window.view = view;

	return DisplayContext{obs_display_create(&info, 0)};
}

@implementation OBSTest
- (void)launch:(NSNotification *)notification contentView:(id)view {
	UNUSED_PARAMETER(notification);

	try {
		if (!view)
			throw "Could not render content for this view";

        // 初始化OBS, 会检查是否存在 libopengl 依赖，没有会抛出异常
        initOBS();

		display = CreateDisplay(view);
        
        // 载入所有的 plugin 模块
        obs_load_all_modules();

        // 创建显示源，理解为渲染显示，不同平台不一样，mac端是 plugins/mac-display-capture.m 文件
        SourceContext source{
            obs_source_create("display_capture", "test source", nullptr, nullptr)};
        if (!source) //会调用 operator T* () 方法
            throw "Couldn't create random test source";

        // 创建场景并将 源 添加到 场景 中
        scene = SceneContext{obs_scene_create("test scene")};
        if (!scene) {
            throw "Couldn't create scene";
        }
        
        // 定义输出
        fileOutput = OutputContext{obs_output_create("ffmpeg_muxer", "simple_file_output", nullptr, nullptr)};
        if (!fileOutput) {
            throw "Failed to create recording FFmpeg output "
                  "(simple file output)";
        }
        
        //配置
        obs_data_t *video_settings = obs_data_create();
        string strPath = "/Users/zhiqiangwei/Movies/test.mkv";
        obs_data_set_string(video_settings, "path", strPath.c_str());
        obs_output_update(fileOutput, video_settings);
        obs_data_release(video_settings);

        //视频渲染回调
		obs_display_add_draw_callback(
			display,
			[](void *, uint32_t, uint32_t) {
            obs_render_main_texture_src_color_only();
			},
			nullptr);
        
        //录制视频编码器
        h264Recording = EncoderContext{obs_video_encoder_create("obs_x264", "simple_h264_recording", nullptr, nullptr)};
        if (!h264Recording){
            throw "Failed to create h264 recording encoder (simple output)";
        }
        //录制音频编码器
        aacRecording = EncoderContext{obs_audio_encoder_create("CoreAudio_AAC", "simple_aac_recording", nullptr, 0, nullptr)};
        if(!aacRecording) {
            throw "Failed to create aacRecording output";
        }

        //将元素链路关联起来
        obs_scene_add(scene, source);
        obs_set_output_source(0, obs_scene_get_source(scene)); //set the scene as the primary draw source and go
        
        obs_encoder_set_video(h264Recording, obs_get_video());
        obs_encoder_set_audio(aacRecording, obs_get_audio());

        obs_output_set_video_encoder(fileOutput, h264Recording);
        obs_output_set_audio_encoder(fileOutput, aacRecording, 0);
        obs_output_set_media(fileOutput, obs_get_video(), obs_get_audio());

        //开始录制
        if (!obs_output_start(fileOutput)) {
            throw(@"fail to obs_output_start");
        }

	} catch (char const *error) {
		NSLog(@"%s\n", error);

		[NSApp terminate:nil];
	}
}

- (void)terminal {
	
	obs_set_output_source(0, nullptr);
	scene.reset();
	display.reset();
    fileOutput.reset();
    h264Recording.reset();
    aacRecording.reset();

	obs_shutdown();
	NSLog(@"Number of memory leaks: %lu", bnum_allocs());
}
@end

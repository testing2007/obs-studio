//
//  REOBSManager.cpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/3.
//

#include "REOBSManager.h"
//#include <sstream>
//#include <iostream>
//#include <stdio.h>
//#include <time.h>
//
//#include <functional>
//#include <memory>

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

/*static*/ REOBSManager* REOBSManager::share() {
    static REOBSManager *_instance = nullptr;
    if(!_instance) {
        _instance = new REOBSManager();
    }
    return _instance;
}

void REOBSManager::setContentView(id view) {
    try {
        if (!view)
            throw "Could not render content for this view";

        // 初始化OBS, 会检查是否存在 libopengl 依赖，没有会抛出异常
        initOBS();

        createDisplay(view);
        
        // 载入所有的 plugin 模块
        obs_load_all_modules();

        // 创建显示源，理解为渲染显示，不同平台不一样，mac端是 plugins/mac-display-capture.m 文件
        OBSSource source = obs_source_create("display_capture", "test source", nullptr, nullptr);
        if (!source) //会调用 operator T* () 方法
            throw "Couldn't create random test source";
        obs_source_release(source);
        
        // 创建场景并将 源 添加到 场景 中
        scene = obs_scene_create("test scene");
        if (!scene) {
            throw "Couldn't create scene";
        }
        obs_scene_release(scene);
        
//        // 本地文件输出
//        fileOutput = obs_output_create("ffmpeg_muxer", "simple_file_output", nullptr, nullptr);
//        if (!fileOutput) {
//            throw "Failed to create recording FFmpeg output "
//                  "(simple file output)";
//        }
//        obs_output_release(fileOutput);
//        // 配置
//        obs_data_t *video_settings = obs_data_create();
//        string strPath = "/Users/zhiqiangwei/Movies/test.mkv";
//        obs_data_set_string(video_settings, "path", strPath.c_str());
//        obs_output_update(fileOutput, video_settings);
//        obs_data_release(video_settings);

        //rtmp 输出
        streamOutput = obs_output_create("rtmp_output", "rtmp_stream", nullptr, nullptr);
        obs_output_release(streamOutput);
        
        //视频渲染回调
        obs_display_add_draw_callback(
            display,
            [](void *, uint32_t, uint32_t) {
            obs_render_main_texture_src_color_only();
            },
            nullptr);
        
        //录制视频编码器
        h264Recording = obs_video_encoder_create("obs_x264", "simple_h264_recording", nullptr, nullptr);
        if (!h264Recording){
            throw "Failed to create h264 recording encoder (simple output)";
        }
        obs_encoder_release(h264Recording);
        //录制音频编码器
        aacRecording = obs_audio_encoder_create("CoreAudio_AAC", "simple_aac_recording", nullptr, 0, nullptr);
        if(!aacRecording) {
            throw "Failed to create aacRecording output";
        }
        obs_encoder_release(aacRecording);

        //将元素链路关联起来
        obs_scene_add(scene, source);
        obs_set_output_source(0, obs_scene_get_source(scene)); //set the scene as the primary draw source and go
        
        obs_encoder_set_video(h264Recording, obs_get_video());
        obs_encoder_set_audio(aacRecording, obs_get_audio());
        
//        // 本地文件输出
//        obs_output_set_video_encoder(fileOutput, h264Recording);
//        obs_output_set_audio_encoder(fileOutput, aacRecording, 0);
//        obs_output_set_media(fileOutput, obs_get_video(), obs_get_audio());

        // stream(rtmp/hls)输出
        OBSData settings = obs_data_create();
        obs_data_release(settings);
        obs_data_set_string(settings, "server", "rtmp://47.93.202.254/hls"); //服务器地址
        obs_data_set_string(settings, "key", "test"); //串流密钥
        streamService = obs_service_create("rtmp_custom", "default_service", settings, nullptr);
        obs_service_release(streamService);

        obs_output_set_video_encoder(streamOutput, h264Recording);
        obs_output_set_audio_encoder(streamOutput, aacRecording, 0);
        obs_output_set_service(streamOutput, streamService);

    } catch (char const *error) {
        printf("%s\n", error);
        this->terminal();
    }
}

void REOBSManager::terminal() {
    obs_set_output_source(0, nullptr);
    obs_shutdown();
    printf("Number of memory leaks: %lu", bnum_allocs());
}

void REOBSManager::startRecord() {
//    //本地文件开始录制
//    if (!obs_output_start(fileOutput)) {
//        printf("fail to obs_output_start");
//    }
    // rtmp 流输出
    if (!obs_output_start(streamOutput)) {
        printf("fail to obs_output_start");
    }
}

void REOBSManager::stopRecord() {
//    本地文件结束录制
//    obs_output_stop(fileOutput);
//    rtmp 流结束
    obs_output_stop(streamOutput);
}

void REOBSManager::createDisplay(id view)
{
    if(display) {
        return ;
    }
    
    gs_init_data info = {};
    info.cx = cx;
    info.cy = cy;
    info.format = GS_BGRA;
    info.zsformat = GS_ZS_NONE;
    info.window.view = view;

    display = obs_display_create(&info, 0);
}

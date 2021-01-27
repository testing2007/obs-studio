//
//  REOBSManager.hpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/3.
//

#ifndef REOBSManagerImpl_hpp
#define REOBSManagerImpl_hpp

#include <stdio.h>
//
#include <util/base.h>
#include "obs.hpp" //包含了 obs.h
#include "REOBSCommon.h"


using namespace std;

class REOBSManager {
public:
    static REOBSManager* share();

    //设置推流窗口
    void setContentView(id view);

    //释放内存
    void terminal();

    //开始录制+推流
    void startRecord();

    //停止录制+推流
    void stopRecord();
    
    //开始推流
    void startPushStream();

    //停止推流
    void stopPushStream();
    
    const vector<REOBSFormatDesc>& getFormats(int &lastSelIndex);
    /// 指定容器格式所支持的音视频编解码
    /// @param formatDesc 指定容器格式
    /// @param vCodecDesc 视频编解码
    /// @param aCodecDesc 音频编解码
    void reloadCodecs(const ff_format_desc *formatDesc,
                      OUT vector<REOBSCodecDesc> &vCodecDesc,
                      OUT int& selVideoCodecIndex,
                      OUT vector<REOBSCodecDesc> &aCodecDesc,
                      OUT int& selAudioCodecIndex);
    
    const ff_format_desc* getCurFormatDesc();
    
private:
    //初始化 OBS
    bool _initOBS();
    void _initAV();
    void _createDisplay(id view);
    bool _createAudioCodec();
    bool _createVideoCodec();
    void _setupFFmpeg();
    
    /// 载入平台支持的容器格式
    int _loadFormats();
    int _findEncoder(vector<REOBSCodecDesc> &codecDesc, const char *name, int id);
    void _updateDefaultCodec(vector<REOBSCodecDesc> &codecDesc, const ff_format_desc *formatDesc, ff_codec_type codecType,  int &defaultCodecId);
    REOBSCodecDesc _getDefaultCodecDesc(const ff_format_desc *formatDesc, ff_codec_type codecType);
    REOBSCodecDesc _createCodec(const ff_codec_desc *codec_desc);
    
private:
    
    REOBSManager();
    ~REOBSManager() {};
    REOBSManager(const REOBSManager&) = delete;
    REOBSManager& operator=(const REOBSManager&) = delete;
    
private:
    int lastSelIndex = -1;
    
    OBSDisplay display;
    OBSScene scene;
    OBSEncoder h264Recording;
    OBSEncoder aacRecording;

    OBSOutput fileOutput;

    OBSService streamService;
    OBSOutput streamOutput;
    
    const ff_format_desc *curFormatDesc;
    
    vector<REOBSFormatDesc> formats;
    vector<REOBSCodecDesc> audioCodecs;
    vector<REOBSCodecDesc> videoCodecs;
};

#define BXG_MGR_SHARE  (REOBSManager::share())

#endif /* REOBSManagerImpl_hpp */

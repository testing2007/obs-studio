//
//  REOBSBasicConfig.hpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/14.
//

#ifndef REOBSBasicConfig_hpp
#define REOBSBasicConfig_hpp

#include <stdio.h>
#include <memory>
#include "REOBSCommon.h"

using namespace std;

class REOBSBasicConfig {
  
public:
    static REOBSBasicConfig* share();
    
    ///outputsChanged: 设置
    void setOutputURL(const char* outputURL);//FFURL
    void setOutputFormat(const char* format, const char* mimeType, const char* extension);//FFFormat + FFFormatMimeType + FFExtension
    void setOutputVideoCodec(int codecId, const char *codecName);//FFVEncoder + FFVEncoderId
    void setOutputVideoBitrate(int64_t videoBitrate);//FFVBitrate
    void setOutputVideoGOPSize(int64_t gopSize);//FFVGOPSize
    
    /// 设置视频编码参数
    /// @param params 参数 key1=value1&key2=value2 格式
    void setOutputVideoCodecParam(const char* params);//FFVCustom
    void setOutputAudioCodec(int codecId, const char *codecName);//FFAEncoder + FFAEncoderId
    void setOutputAudioBitrate(int64_t audioBitrate);//FFABitrate
    void setOutputAudioMixes(int64_t audioMixes);//FFAudioMixes
    /// 设置音频编码参数
    /// @param params 参数 key1=value1&key2=value2 格式
    void setOutputAudioCodecParam(const char* params);//FFACustom
    
    ///设置完成以后，需要调用保存接口，才能最终写入文件中
    void saveCfg();

    ///获取
    const char* getOutputURL();
    const char* getOutputFormat();
    const char* getOutputFormatMimeType();
    const char* getOutputFormatExtension();
    const char* getOutputVideoCodecName();
    int64_t getOutputVideoCodecId();
    int64_t getOutputVideoBitrate();
    int64_t getOutputVideoGOPSize();
    const char* getOutputVideoCodecParam();
    const char* getOutputAudioCodecName();
    int64_t getOutputAudioCodecId();
    const char* getOutputAudioCodecParam();
    int64_t getOutputAudioBitrate();
    int64_t getOutputAudioMixes();


private:
    REOBSBasicConfig();
    bool _initConfig();
    bool _initBasicConfigDefaults();

    void _clearChange() {
        outputsChanged = false;
    }
private:
//    generalChanged = false;
//    stream1Changed = false;
    bool outputsChanged;
//    audioChanged = false;
//    videoChanged = false;
//    hotkeysChanged = false;
//    advancedChanged = false;
//    EnableApplyButton(false);
    
    
private:
    config_t* basicConfig;//配置文件
};

#endif /* REOBSBasicConfig_hpp */

#define REOBSBasicConfigInstance (REOBSBasicConfig::share())

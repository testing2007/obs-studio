//
//  REOBSBasicConfig.cpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/14.
//

#include "REOBSBasicConfig.h"
#include "REOBSCommon.h"
#include "libff/ff-util.h"

/*static*/ REOBSBasicConfig* REOBSBasicConfig::share() {
    static REOBSBasicConfig* instance = nullptr;
    if(instance == nullptr) {
        instance = new REOBSBasicConfig();
    }
    return instance;
}

void REOBSBasicConfig::setOutputURL(const char* outputURL) {
    config_set_string(basicConfig, "AdvOut", "FFURL", outputURL);
    outputsChanged = true;
}

void REOBSBasicConfig::setOutputFormat(const struct ff_format_desc* formatDesc) {
        if(formatDesc != nullptr) {
            config_set_string(basicConfig, "AdvOut", "FFFormat", ff_format_desc_name(formatDesc));
            config_set_string(basicConfig, "AdvOut", "FFFormatMimeType", ff_format_desc_mime_type(formatDesc));
            const char *ext = ff_format_desc_extensions(formatDesc);
            string extStr = ext ? ext : "";

            char *comma = strchr(&extStr[0], ',');
            if (comma)
                *comma = 0;
            config_set_string(basicConfig, "AdvOut", "FFExtension", extStr.c_str());// FFExtension 与 RecFormat 相对， 表示输出的容器格式；
        } else {
            config_set_string(basicConfig, "AdvOut", "FFFormat", nullptr);
            config_set_string(basicConfig, "AdvOut", "FFFormatMimeType", nullptr);
            config_remove_value(basicConfig, "AdvOut", "FFExtension");
        }
        outputsChanged = true;
}

void REOBSBasicConfig::setOutputVideoCodec(const struct ff_codec_desc *codecDesc) {
        if(codecDesc != nullptr) {
            int encoderId = ff_codec_desc_id(codecDesc);
            config_set_int(basicConfig, "AdvOut", "FFVEncoderId", encoderId);
            if (encoderId != 0)
                config_set_string(basicConfig, "AdvOut", "FFVEncoder", ff_codec_desc_name(codecDesc));
            else
                config_set_string(basicConfig, "AdvOut", "FFVEncoder", nullptr);

            outputsChanged = true;
        }
}

void REOBSBasicConfig::setOutputVideoBitrate(int64_t videoBitrate) {
    config_set_int(basicConfig, "AdvOut", "FFVBitrate", videoBitrate);
    outputsChanged = true;
}

void REOBSBasicConfig::setOutputVideoGOPSize(int64_t gopSize) {
    config_set_int(basicConfig, "AdvOut", "FFVGOPSize", gopSize);
    outputsChanged = true;
}

void REOBSBasicConfig::setOutputVideoCodecParam(const char* params) {
    config_set_string(basicConfig, "AdvOut", "FFVCustom", params);
    outputsChanged = true;
}

void REOBSBasicConfig::setOutputAudioCodec(const struct ff_codec_desc *codecDesc) {
    if(codecDesc != nullptr) {
        int encoderId = ff_codec_desc_id(codecDesc);
        config_set_int(basicConfig, "AdvOut", "FFAEncoderId", encoderId);
        if (encoderId != 0)
            config_set_string(basicConfig, "AdvOut", "FFAEncoder", ff_codec_desc_name(codecDesc));
        else
            config_set_string(basicConfig, "AdvOut", "FFAEncoder", nullptr);

        outputsChanged = true;
    }
}

void REOBSBasicConfig::setOutputAudioCodecParam(const char* params) {
    config_set_string(basicConfig, "AdvOut", "FFACustom", params);
    outputsChanged = true;
}

void REOBSBasicConfig::setOutputAudioBitrate(int64_t audioBitrate) {
    config_set_int(basicConfig, "AdvOut", "FFABitrate", audioBitrate);
    outputsChanged = true;
}

void REOBSBasicConfig::setOutputAudioMixes(int64_t audioMixes) {
    config_set_int(basicConfig, "AdvOut", "FFAudioMixes", audioMixes);
    outputsChanged = true;
}

void REOBSBasicConfig::saveCfg() {
    if(outputsChanged) {
//        config_save(basicConfig);
        config_save_safe(basicConfig, "tmp", nullptr);

        _clearChange();
    }
}

const char* REOBSBasicConfig::getOutputURL() {
    const char* ret = config_get_string(basicConfig, "AdvOut", "FFURL");
    return ret == nullptr ? "" : ret;
}

const char* REOBSBasicConfig::getOutputFormat() {
    const char* ret = config_get_string(basicConfig, "AdvOut", "FFFormat");
    return ret == nullptr ? "" : ret;
}

const char* REOBSBasicConfig::getOutputFormatMimeType() {
    const char* ret = config_get_string(basicConfig, "AdvOut", "FFFormatMimeType");
    return ret == nullptr ? "" : ret;
}

const char* REOBSBasicConfig::getOutputFormatExtension() {
    const char* ret = config_get_string(basicConfig, "AdvOut", "FFExtension");
    return ret == nullptr ? "" : ret;
}

const char* REOBSBasicConfig::getOutputVideoCodecName()  {
    const char* ret = config_get_string(basicConfig, "AdvOut", "FFVEncoder");
    return ret == nullptr ? "" : ret;
}

int64_t REOBSBasicConfig::getOutputVideoCodecId() {
    return config_get_int(basicConfig, "AdvOut", "FFVEncoderId");
}


int64_t REOBSBasicConfig::getOutputVideoBitrate() {
    return config_get_int(basicConfig, "AdvOut", "FFVBitrate");
}

int64_t REOBSBasicConfig::getOutputVideoGOPSize() {
    return config_get_int(basicConfig, "AdvOut", "FFVGOPSize");
}

const char* REOBSBasicConfig::getOutputVideoCodecParam() {
    const char* ret = config_get_string(basicConfig, "AdvOut", "FFVCustom");
    return ret == nullptr ? "" : ret;
}

const char* REOBSBasicConfig::getOutputAudioCodecName() {
    const char* ret = config_get_string(basicConfig, "AdvOut", "FFAEncoder");
    return ret == nullptr ? "" : ret;
}

int64_t REOBSBasicConfig::getOutputAudioCodecId() {
    return config_get_int(basicConfig, "AdvOut", "FFAEncoderId");
}

const char* REOBSBasicConfig::getOutputAudioCodecParam() {
    const char* ret = config_get_string(basicConfig, "AdvOut", "FFACustom");
    return ret == nullptr ? "" : ret;
}

int64_t REOBSBasicConfig::getOutputAudioBitrate() {
    return config_get_int(basicConfig, "AdvOut", "FFABitrate");
}

int64_t REOBSBasicConfig::getOutputAudioMixes() {
    return config_get_int(basicConfig, "AdvOut", "FFAudioMixes");
}

REOBSBasicConfig::REOBSBasicConfig(){
    outputsChanged = false;
    basicConfig = nullptr;
    
    ff_init();
    
    _initConfig();
}

bool REOBSBasicConfig::_initConfig() {
    char dirPath[512];
    int ret = REOBSCommon::getProfilePath(dirPath, sizeof(dirPath));
    if (ret <= 0)
        return false;

    char path[512];
    sprintf(path, "%s/%s", dirPath, BASIC_CONFIG_NAME);

//    if(!os_file_exists(path)) {
//
//        if(!basicConfig) {
//            return false;
//        }
//    } else {
//        return true;
//    }
    basicConfig = config_create(path);
    int code = config_open(&basicConfig, path, CONFIG_OPEN_ALWAYS);
    if (code != CONFIG_SUCCESS) {
        blog(LOG_ERROR, "fail to open basic.ini:%d", code);
        return false;
    }
 

//    _initBasicConfigDefaults();

    return true;
}

static const double scaled_vals[] = {1.0,         1.25, (1.0 / 0.75), 1.5,
                     (1.0 / 0.6), 1.75, 2.0,          2.25,
                     2.5,         2.75, 3.0,          0.0};

//bool REOBSBasicConfig::_initBasicConfigDefaults() {
//    uint32_t cx = 1920;
//    uint32_t cy = 1080;
//
//    config_set_default_string(basicConfig, "Output", "Mode", "Simple");
//
//    config_set_default_string(basicConfig, "SimpleOutput", "FilePath",REOBSCommon::getDefaultVideoSavePath().c_str());
//    config_set_default_string(basicConfig, "SimpleOutput", "RecFormat",
//                  "mkv");
//    config_set_default_uint(basicConfig, "SimpleOutput", "VBitrate", 2500);
//    config_set_default_uint(basicConfig, "SimpleOutput", "ABitrate", 160);
//    config_set_default_bool(basicConfig, "SimpleOutput", "UseAdvanced",
//                false);
//    config_set_default_bool(basicConfig, "SimpleOutput", "EnforceBitrate",
//                true);
//    config_set_default_string(basicConfig, "SimpleOutput", "Preset",
//                  "veryfast");
//    config_set_default_string(basicConfig, "SimpleOutput", "NVENCPreset",
//                  "hq");
//    config_set_default_string(basicConfig, "SimpleOutput", "RecQuality",
//                  "Stream");
//    config_set_default_bool(basicConfig, "SimpleOutput", "RecRB", false);
//    config_set_default_int(basicConfig, "SimpleOutput", "RecRBTime", 20);
//    config_set_default_int(basicConfig, "SimpleOutput", "RecRBSize", 512);
//    config_set_default_string(basicConfig, "SimpleOutput", "RecRBPrefix",
//                  "Replay");
//
//    config_set_default_bool(basicConfig, "AdvOut", "ApplyServiceSettings",
//                true);
//    config_set_default_bool(basicConfig, "AdvOut", "UseRescale", false);
//    config_set_default_uint(basicConfig, "AdvOut", "TrackIndex", 1);
//    config_set_default_string(basicConfig, "AdvOut", "Encoder", "obs_x264");
//
//    config_set_default_string(basicConfig, "AdvOut", "RecType", "Standard");
//
//    config_set_default_string(basicConfig, "AdvOut", "RecFilePath",
//                              REOBSCommon::getDefaultVideoSavePath().c_str());
//    config_set_default_string(basicConfig, "AdvOut", "RecFormat", "mkv");
//    config_set_default_bool(basicConfig, "AdvOut", "RecUseRescale", false);
//    config_set_default_uint(basicConfig, "AdvOut", "RecTracks", (1 << 0));
//    config_set_default_string(basicConfig, "AdvOut", "RecEncoder", "none");
//    config_set_default_uint(basicConfig, "AdvOut", "FLVTrack", 1);
//
//    config_set_default_bool(basicConfig, "AdvOut", "FFOutputToFile", true);
//    config_set_default_string(basicConfig, "AdvOut", "FFFilePath",
//                              REOBSCommon::getDefaultVideoSavePath().c_str());
//    config_set_default_string(basicConfig, "AdvOut", "FFExtension", "mp4");
//    config_set_default_uint(basicConfig, "AdvOut", "FFVBitrate", 2500);
//    config_set_default_uint(basicConfig, "AdvOut", "FFVGOPSize", 250);
//    config_set_default_bool(basicConfig, "AdvOut", "FFUseRescale", false);
//    config_set_default_bool(basicConfig, "AdvOut", "FFIgnoreCompat", false);
//    config_set_default_uint(basicConfig, "AdvOut", "FFABitrate", 160);
//    config_set_default_uint(basicConfig, "AdvOut", "FFAudioMixes", 1);
//
//    config_set_default_uint(basicConfig, "AdvOut", "Track1Bitrate", 160);
//    config_set_default_uint(basicConfig, "AdvOut", "Track2Bitrate", 160);
//    config_set_default_uint(basicConfig, "AdvOut", "Track3Bitrate", 160);
//    config_set_default_uint(basicConfig, "AdvOut", "Track4Bitrate", 160);
//    config_set_default_uint(basicConfig, "AdvOut", "Track5Bitrate", 160);
//    config_set_default_uint(basicConfig, "AdvOut", "Track6Bitrate", 160);
//
//    config_set_default_bool(basicConfig, "AdvOut", "RecRB", false);
//    config_set_default_uint(basicConfig, "AdvOut", "RecRBTime", 20);
//    config_set_default_int(basicConfig, "AdvOut", "RecRBSize", 512);
//
//    config_set_default_uint(basicConfig, "Video", "BaseCX", cx);
//    config_set_default_uint(basicConfig, "Video", "BaseCY", cy);
//
//    /* don't allow BaseCX/BaseCY to be susceptible to defaults changing */
//    if (!config_has_user_value(basicConfig, "Video", "BaseCX") ||
//        !config_has_user_value(basicConfig, "Video", "BaseCY")) {
//        config_set_uint(basicConfig, "Video", "BaseCX", cx);
//        config_set_uint(basicConfig, "Video", "BaseCY", cy);
//        config_save_safe(basicConfig, "tmp", nullptr);
//    }
//
//    config_set_default_string(basicConfig, "Output", "FilenameFormatting",
//                  "%CCYY-%MM-%DD %hh-%mm-%ss");
//
//    config_set_default_bool(basicConfig, "Output", "DelayEnable", false);
//    config_set_default_uint(basicConfig, "Output", "DelaySec", 20);
//    config_set_default_bool(basicConfig, "Output", "DelayPreserve", true);
//
//    config_set_default_bool(basicConfig, "Output", "Reconnect", true);
//    config_set_default_uint(basicConfig, "Output", "RetryDelay", 10);
//    config_set_default_uint(basicConfig, "Output", "MaxRetries", 20);
//
//    config_set_default_string(basicConfig, "Output", "BindIP", "default");
//    config_set_default_bool(basicConfig, "Output", "NewSocketLoopEnable",
//                false);
//    config_set_default_bool(basicConfig, "Output", "LowLatencyEnable",
//                false);
//
//    int i = 0;
//    uint32_t scale_cx = cx;
//    uint32_t scale_cy = cy;
//
//    /* use a default scaled resolution that has a pixel count no higher
//     * than 1280x720 */
//    while (((scale_cx * scale_cy) > (1280 * 720)) && scaled_vals[i] > 0.0) {
//        double scale = scaled_vals[i++];
//        scale_cx = uint32_t(double(cx) / scale);
//        scale_cy = uint32_t(double(cy) / scale);
//    }
//
//    config_set_default_uint(basicConfig, "Video", "OutputCX", scale_cx);
//    config_set_default_uint(basicConfig, "Video", "OutputCY", scale_cy);
//
//    /* don't allow OutputCX/OutputCY to be susceptible to defaults
//     * changing */
//    if (!config_has_user_value(basicConfig, "Video", "OutputCX") ||
//        !config_has_user_value(basicConfig, "Video", "OutputCY")) {
//        config_set_uint(basicConfig, "Video", "OutputCX", scale_cx);
//        config_set_uint(basicConfig, "Video", "OutputCY", scale_cy);
//        config_save_safe(basicConfig, "tmp", nullptr);
//    }
//
//    config_set_default_uint(basicConfig, "Video", "FPSType", 0);
//    config_set_default_string(basicConfig, "Video", "FPSCommon", "30");
//    config_set_default_uint(basicConfig, "Video", "FPSInt", 30);
//    config_set_default_uint(basicConfig, "Video", "FPSNum", 30);
//    config_set_default_uint(basicConfig, "Video", "FPSDen", 1);
//    config_set_default_string(basicConfig, "Video", "ScaleType", "bicubic");
//    config_set_default_string(basicConfig, "Video", "ColorFormat", "NV12");
//    config_set_default_string(basicConfig, "Video", "ColorSpace", "709");
//    config_set_default_string(basicConfig, "Video", "ColorRange",
//                  "Partial");
//
//    config_set_default_string(basicConfig, "Audio", "MonitoringDeviceId",
//                  "default");
//    config_set_default_string(
//        basicConfig, "Audio", "MonitoringDeviceName",
//        "Basic.Settings.Advanced.Audio.MonitoringDevice"
//            ".Default");
//    config_set_default_uint(basicConfig, "Audio", "SampleRate", 48000);
//    config_set_default_string(basicConfig, "Audio", "ChannelSetup",
//                  "Stereo");
//    config_set_default_double(basicConfig, "Audio", "MeterDecayRate",
//                  VOLUME_METER_DECAY_FAST);
//    config_set_default_uint(basicConfig, "Audio", "PeakMeterType", 0);
    
//    return true;
//}


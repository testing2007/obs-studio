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
#include "libff/ff-util.h"
#include "libobs/util/util.hpp"
// 接口参考 window-basic-main-profile.cpp 和 ff-util.h 文件的实现


class OBSFFDeleter {
public:
    void operator()(const ff_format_desc *format)
    {
        ff_format_desc_free(format);
    }
    void operator()(const ff_codec_desc *codec)
    {
        ff_codec_desc_free(codec);
    }
};
using OBSFFCodecDesc = std::unique_ptr<const ff_codec_desc, OBSFFDeleter>;
using OBSFFFormatDesc = std::unique_ptr<const ff_format_desc, OBSFFDeleter>;

class REOBSBasicConfig {
  
public:
    static REOBSBasicConfig* share();
    
    ff_format_desc* getFormatDesc();
    ff_format_desc* getFormatDescByIndex(int index);
    ff_format_desc* getFormatDescByName(const char* name);
    
    ff_codec_desc* codecDescs(ff_format_desc* formatDesc, bool isIgnoreCompatability);
    // ff_codec_supported(formatDesc, ignore_compatability));
    ff_codec_desc* getCodecDesc();
    ff_codec_desc* getCodecDescByIdId(int idValue);
    ff_codec_desc* getCodecDescByName(const char* name);
    
//    // Codec Description
//    const struct ff_codec_desc *
//    ff_codec_supported(const struct ff_format_desc *format_desc,
//                       bool ignore_compatability);
//    void ff_codec_desc_free(const struct ff_codec_desc *codec_desc);
//    const char *ff_codec_desc_name(const struct ff_codec_desc *codec_desc);
//    const char *ff_codec_desc_long_name(const struct ff_codec_desc *codec_desc);
//    enum ff_codec_type ff_codec_desc_type(const struct ff_codec_desc *codec_desc);
//    bool ff_codec_desc_is_alias(const struct ff_codec_desc *codec_desc);
//    const char *ff_codec_desc_base_name(const struct ff_codec_desc *codec_desc);
//    int ff_codec_desc_id(const struct ff_codec_desc *codec_desc);
//    const struct ff_codec_desc *
//    ff_codec_desc_next(const struct ff_codec_desc *codec_desc);
//
//    // Format Description
//    const struct ff_format_desc *ff_format_supported();
//    void ff_format_desc_free(const struct ff_format_desc *format_desc);
//    const char *ff_format_desc_name(const struct ff_format_desc *format_desc);
//    const char *ff_format_desc_long_name(const struct ff_format_desc *format_desc);
//    const char *ff_format_desc_mime_type(const struct ff_format_desc *format_desc);
//    const char *ff_format_desc_extensions(const struct ff_format_desc *format_desc);
//    bool ff_format_desc_has_audio(const struct ff_format_desc *format_desc);
//    bool ff_format_desc_has_video(const struct ff_format_desc *format_desc);
//    int ff_format_desc_audio(const struct ff_format_desc *format_desc);
//    int ff_format_desc_video(const struct ff_format_desc *format_desc);
//    const char *
//    ff_format_desc_get_default_name(const struct ff_format_desc *format_desc,
//                                    enum ff_codec_type codec_type);
//    const struct ff_format_desc *
//    ff_format_desc_next(const struct ff_format_desc *format_desc);
    
private:
    REOBSBasicConfig();

private:
    bool _initCfg();
    bool _initBasicConfigDefaults();


private:
    OBSFFFormatDesc formats;
    OBSFFCodecDesc codecs;
    
    ConfigFile basicConfig;//配置文件

};

#endif /* REOBSBasicConfig_hpp */

#define REOBSAVConfigInstance (REOBSBasicConfig::share())

//strcat(path, "/basic.ini");
//
//ConfigFile config;
//if (config.Open(path, CONFIG_OPEN_EXISTING) != 0)
//    continue;
//
//const char *curName =
//    config_get_string(config, "General", "Name");
//if (astrcmpi(curName, name) == 0) {
//    outputPath = ent.path;
//    break;
//}

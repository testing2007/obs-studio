//
//  REOBSCommon.hpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/14.
//

#ifndef REOBSCommon_hpp
#define REOBSCommon_hpp

#include <stdio.h>
#include <string>
#include <vector>
#include "REOBSCommonMacro.h"
#include "util/base.h"
#include "util/platform.h"
#include "libff/ff-util.h"
#include "libobs/util/util.hpp"
#include "libobs/util/config-file.h"

using namespace std;

#define OUT
#define IN

struct REOBSFormatDesc {
    const char *name = nullptr;
    const char *mimeType = nullptr;
    const ff_format_desc *desc = nullptr;

    inline REOBSFormatDesc() = default;
    inline REOBSFormatDesc(const char *name, const char *mimeType,
              const ff_format_desc *desc = nullptr)
        : name(name), mimeType(mimeType), desc(desc)
    {
    }

    bool operator==(const REOBSFormatDesc &f) const
    {
        if (strcmp(name, f.name) != 0)
            return false;
        return strcmp(mimeType, f.mimeType);
    }
};

struct REOBSCodecDesc {
    const char *name = nullptr;
    int id = 0;
//    bool isDefaultCodec = false;
    int defaultCodecIndex = -1;

    inline REOBSCodecDesc() = default;
    inline REOBSCodecDesc(const char *name, int id) : name(name), id(id) {}

    bool operator==(const REOBSCodecDesc &codecDesc) const
    {
        if (id != codecDesc.id)
            return false;
        int ret = strcmp(name, codecDesc.name);
        return ret==0 ? true : false;
    }
};

class REOBSCommon {

public:
    static int getProfilePath(char *path, int size);
    static string getDefaultVideoSavePath();
};


#endif /* REOBSCommon_hpp */

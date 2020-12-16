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
#include "REOBSCommonMacro.h"
#include "util/base.h"
#include "util/platform.h"

using namespace std;
class REOBSCommon {

public:
    static int getProfilePath(char *path, int size);
    static string getDefaultVideoSavePath();
};


#endif /* REOBSCommon_hpp */

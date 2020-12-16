//
//  REOBSCommon.cpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/14.
//

#include "REOBSCommon.h"
#include <Foundation/Foundation.h>

int REOBSCommon::getProfilePath(char *path, int size)
{
    //TODO: obs-test 最好能获取 appName 的系统API来代替
    char server_cfg_path[512];
    int result = os_get_config_path(server_cfg_path, sizeof(server_cfg_path), APP_CONFIG_PATH);
    
    if(result < 0) {
        blog(LOG_DEBUG, "fail to get config path");
        return -1;
    }

    if (os_mkdirs(server_cfg_path) == MKDIR_ERROR) {
        return -1;
    }

    return sprintf(path, "%s", server_cfg_path);
}

string REOBSCommon::getDefaultVideoSavePath()
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *url = [fm URLForDirectory:NSMoviesDirectory
                inDomain:NSUserDomainMask
               appropriateForURL:nil
                  create:true
                   error:nil];

    if (!url)
        return getenv("HOME");

    return url.path.fileSystemRepresentation;
}

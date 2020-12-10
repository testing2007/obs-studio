//
//  main.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/16.
//

#import <Cocoa/Cocoa.h>
//#import "REOBS.h"

//struct config_data;
//typedef struct config_data config_t;
//
//struct obs_data;
//typedef struct obs_data obs_data_t;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
    }
    return NSApplicationMain(argc, argv);

//    // 初始化推流服务配置
//    if (!gInitOBS()) {
//        return -1;
//    }
//    if(!REOBSConfigInstance->initService()) {
//        blog(LOG_ERROR, "fail to initialize service");
//        return -1;
//    }
//    //修改配置调用
//    const char *server = "rtmp://47.93.202.254/hls";
//    const char *key = "test";
//    const char isNeedAuthorization = true;
//    const char *userName = "username";
//    const char *password = "password";
//    REOBSConfigInstance->saveCustomService(server, key, isNeedAuthorization, userName, password);
//    return 0;
}

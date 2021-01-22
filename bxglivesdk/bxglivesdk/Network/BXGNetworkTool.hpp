//
//  BXGNetworkTool.hpp
//  bxglivesdk
//
//  Created by ZhiQiang wei on 2021/1/22.
//

#ifndef BXGNetworkBB_hpp
#define BXGNetworkBB_hpp

#include <stdio.h>

//网络库
//#define CPPHTTPLIB_OPENSSL_SUPPORT
#include "cpp-httplib/httplib.h"

class BXGPushStreamModel;

class BXGNetworkTool {
public:
    static BXGNetworkTool* share();

    bool getPushStreamData(BXGPushStreamModel **data, std::string &msg);

private:
    std::string getInfo(char* uri);

};

#endif /* BXGNetworkBB_hpp */

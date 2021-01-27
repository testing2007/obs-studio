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

    //type=0, hls推流; type =1, flv推流
    bool getPushStreamData(BXGPushStreamModel &data, int type, int& roomId, std::string &msg);

private:
    BXGNetworkTool();
    
private:
    std::string getInfo(std::string &uri);
    httplib::Client *requestHandle;
};

#endif /* BXGNetworkBB_hpp */

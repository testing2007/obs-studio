//
//  BXGNetworkTool.cpp
//  bxglivesdk
//
//  Created by ZhiQiang wei on 2021/1/22.
//

#include "BXGNetworkTool.hpp"
#include "BXGNetworkResult.hpp"
#include "BXGPushStreamModel.hpp"

template<typename T>
class Convert {
    public:
    static bool parseModel(const BXGNetworkResult& result, T& data, std::string &msg) {
        bool bSuccess = false;
        if(result.status / 2 == 100 ) {
            if(result.data.is_null()) {
                msg = result.msg;
                bSuccess = true;
            } else {
                try {
                    data = result.data.get<T>();
                    msg = result.msg;
                    bSuccess = true;
                } catch (std::exception e) {
                    msg = result.msg;
                    bSuccess = false;
                }
            }
        } else {
            msg = "失败";
            bSuccess = false;
        }
        return bSuccess;
    }
};

/*static*/ BXGNetworkTool* BXGNetworkTool::share() {
    static BXGNetworkTool *_instance = nullptr;
    if(!_instance) {
        _instance = new BXGNetworkTool();
    }
    return _instance;
}

std::string BXGNetworkTool::getInfo(std::string &uri) {
    // HTTP
    httplib::Client cli("http://localhost:9000");

    // HTTPS
    //httplib::Client cli("https://cpp-httplib-server.yhirose.repl.co");

    auto res = cli.Get(uri.c_str());
    return res->body;
}

bool BXGNetworkTool::getPushStreamData(BXGPushStreamModel &data, int type, int& roomId, std::string &msg) {
    std::string uri;
    std::string params;
    std::string authCode = "&authCode=push_" + std::to_string(roomId);
    if(type == 0) {
        params = "?liveType=hls" + authCode;
    } else {
        params = "?liveType=flv" + authCode;
    }
    uri = "/getPushInfo" + params;
    const std::string &info = this->getInfo(uri);
    const BXGNetworkResult &result = BXGNetworkResult::result(info);
    
    bool bSuccess = Convert<BXGPushStreamModel>::parseModel(result, data, msg);
    if(bSuccess) {
        roomId = atoi(data.roomId.c_str()) + 1;
    }
    return bSuccess;
}

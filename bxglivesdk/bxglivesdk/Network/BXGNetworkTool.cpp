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
//                data= (T)0;
                msg = result.msg;
                bSuccess = true;
            } else {
                try {
                    data = result.data.get<T>();
                    msg = result.msg;
                    bSuccess = true;
                } catch (std::exception e) {
//                    data= (T)0;
                    msg = result.msg;
                    bSuccess = false;
                }
            }
        } else {
//            data= (T)0;
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

bool BXGNetworkTool::getPushStreamData(BXGPushStreamModel &data, int type, std::string &msg) {
    std::string uri;
    if(type == 0) {
        uri = "/getPushInfo/hls";
    } else {
        uri = "/getPushInfo/flv";
    }
    const std::string &info = this->getInfo(uri);
    const BXGNetworkResult &result = BXGNetworkResult::result(info);
    return Convert<BXGPushStreamModel>::parseModel(result, data, msg);
}

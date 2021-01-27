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

BXGNetworkTool::BXGNetworkTool() {
    // HTTP
    requestHandle = new httplib::Client("http://localhost:9000");
    httplib::Headers headers;
    headers.insert(std::make_pair("bxg-origin", "bxg"));
    headers.insert(std::make_pair("bxg-platform", "mac"));
    requestHandle->set_default_headers(headers);
    // HTTPS
    //httplib::Client cli("https://cpp-httplib-server.yhirose.repl.co");
}

std::string BXGNetworkTool::getInfo(std::string &uri) {
    auto res = requestHandle->Get(uri.c_str());
    return res->body;
}

bool BXGNetworkTool::getPushStreamData(BXGPushStreamModel& data, PUSH_CATEGORY_TYPE pushCategory, PUSH_STYLE_TYPE pushStyle, const std::string& authCode, std::string &msg) {
    // param
    std::string category = (pushCategory==0) ? "service" : "param";
    std::string style = (pushStyle==0) ? "hls" : "flv";
    std::string params = "?pushCategory=" + category  + "&pushStyle="+ style + "&authCode="+ authCode;

    // uri
    std::string uri;
    uri = "/getPushInfo" + params;
    const std::string &info = this->getInfo(uri);
    const BXGNetworkResult &result = BXGNetworkResult::result(info);
    
    bool bSuccess = Convert<BXGPushStreamModel>::parseModel(result, data, msg);
    return bSuccess;
}

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
        static bool parseModel(const BXGNetworkResult& result, T** data, std::string &msg) {
            bool bSuccess = false;
            if(result.status / 2 == 100 ) {
                if(result.data.is_null()) {
                    *data= nullptr;
                    msg = result.msg;
                    bSuccess = true;
                } else {
                    try {
                        const T &tempData = result.data.get<T>();
                        *data = (T*)malloc(sizeof(T));
                        memcpy((void*)*data, (void*)(&tempData), sizeof(T));
                        msg = result.msg;
                        bSuccess = true;
                    } catch (std::exception e) {
                        *data = nullptr;
                        msg = result.msg;
                        bSuccess = false;
                    }
                }
            } else {
                *data = nullptr;
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

std::string BXGNetworkTool::getInfo(char* uri) {
    // HTTP
    httplib::Client cli("http://localhost:9000");

    // HTTPS
    //httplib::Client cli("https://cpp-httplib-server.yhirose.repl.co");

    auto res = cli.Get(uri);
    return res->body;
}

bool BXGNetworkTool::getPushStreamData(BXGPushStreamModel **data, std::string &msg) {
    const std::string &info = this->getInfo("/getPushInfo");
    const BXGNetworkResult &result = BXGNetworkResult::result(info);
    return Convert<BXGPushStreamModel>::parseModel(result, data, msg);
}

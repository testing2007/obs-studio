//
//  BXGNetworkTool.hpp
//  bxglivesdk
//
//  Created by ZhiQiang wei on 2021/1/21.
//

#ifndef BXGNetworkTool_hpp
#define BXGNetworkTool_hpp


#include <stdio.h>
#include <iostream>

//JOSN库
#include "nlohmann/json.hpp"
using json = nlohmann::json;


class  BXGNetworkResult {
public:
    int status;
    std::string msg;
    json data;

    static BXGNetworkResult result(const std::string& res);
};




//template <typename T>
//class  BXGNetworkResultT {
//public:
//    int status;
//    std::string message;
//    const T* data;
//
//public:
//    static BXGNetworkResultT parse(std::string& j) {
//        auto tempJson = json::parse(j);
//        BXGNetworkResultT<T> result;
//        result.status = tempJson["status"];
//        result.message = tempJson["message"];
//        json &jsonData = tempJson["data"];
//        if(jsonData.is_null()) {
//            result.data = nullptr;
//        } else {
//            try {
//                const T &tempData = jsonData.get<T>();
//                result.data = (T*)malloc(sizeof(T));
//                memcpy((void*)result.data, (void*)(&tempData), sizeof(T));
//            } catch (std::exception e) {
//                result.data = nullptr;
//            }
//        }
//
//        return result;
//    }
//};


//#ifdef __cplusplus
//}
//#endif

#endif /* BXGNetworkTool_hpp */

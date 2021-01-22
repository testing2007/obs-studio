//
//  BXGNetworkTool.cpp
//  bxglivesdk
//
//  Created by ZhiQiang wei on 2021/1/21.
//

#include "BXGNetworkResult.hpp"
#include "BXGNetworkTool.hpp"
//#include "BXGNetworkBB.hpp"

BXGNetworkResult BXGNetworkResult::result(const std::string& res){
    auto tempJson = json::parse(res);
    BXGNetworkResult result;
    result.status = tempJson["status"];
    result.msg = tempJson["message"];
    result.data = tempJson["data"];
    
    return result;
}







//template <typename T>
///*static*/
//BXGNetworkResult<T> BXGNetworkResult<T>::parse(std::string& res) {
//    auto tempJson = json::parse(res);
//    BXGNetworkResult<T> result;
//    result.status = tempJson["status"];
//    result.message = tempJson["message"];
//    json &jsonData = tempJson["data"];
//    if(jsonData.is_null()) {
//        result.data = nullptr;
//    } else {
//        try {
//            const T &tempData = jsonData.get<T>();
//            result.data = (T*)malloc(sizeof(T));
//            memcpy((void*)result.data, (void*)(&tempData), sizeof(T));
//        } catch (std::exception e) {
//            result.data = nullptr;
//        }
//    }
//
//    return result;
//}
    


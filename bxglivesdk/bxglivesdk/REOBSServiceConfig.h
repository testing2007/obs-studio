//
//  REOBSConfig.hpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/9.
//

#ifndef REOBSConfig_hpp
#define REOBSConfig_hpp

#include <stdio.h>
#include "obs.hpp" //包含了 obs.h

class REOBSServiceConfig {

public:
    static REOBSServiceConfig* share();
    
public:
    
    /// 首先按照用户设置初始化推流服务，如果没有，启动默认推流服务
    bool initService();
    
    // 生成的直播地址：server + key; （key 可以依靠 username + password 来生成
    //    const char *server = "rtmp://47.93.202.254/hls"; //hls 是 nginx 配置的直播名称
    //    const char *key = "test";                        //是直播密钥，可以通过 应用服务器进行返回
    //    const char isNeedAuthorization = true;
    //    const char *userName = "username";
    //    const char *password = "password";
    //    REOBSConfigInstance->saveCustomService(server, key, isNeedAuthorization, userName, password);
    /// 保存自定义推流服务
    /// @param server 自定义推流地址
    /// @param key        推流密钥（或 推流视频名称 ）
    /// @param isNeedAuthorization 是否需要验证
    /// @param username 验证用户名
    /// @param password 验证密码
    void saveCustomService(const char* server, const char *key, bool isNeedAuthorization, const char* username, const char *password);
    
    
    /// 保存第三方推流服务
    /// @param serviceName 第三方推流服务名称
    /// @param server 第三方推流服务地址
    /// @param key        推流密钥（或 推流视频名称 ）
    void saveDefaultService(const char* serviceName, const char* server, const char *key);

    
    /// 获取配置目录路径， 失败返回负数，否则正确
    /// @param path 返回的路径
    /// @param size 空间字符串大小
//    int getProfilePath(char *path, int size);

    obs_service_t* getService();

private:
    bool _loadService();
    void _saveService(bool isCustom, const char* serviceName, const char* server, const char *key, bool isNeedAuthorization, const char* username, const char *password);
    void _setService(obs_service_t *newService);
    void _saveService();

private:
    REOBSServiceConfig() ;

private:
    OBSService service;
};

#define REOBSConfigInstance  (REOBSServiceConfig::share())

#endif /* REOBSConfig_hpp */

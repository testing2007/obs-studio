//
//  REOBSServiceConfig.cpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/9.
//

#include "REOBSServiceConfig.h"
#include "REOBSCommonMacro.h"
#include "REOBSCommon.h"
#include "util/platform.h"
#include <string.h>
#include "libobs/util/config-file.h"


/*static*/
REOBSServiceConfig* REOBSServiceConfig::share() {
    static REOBSServiceConfig* instance = nullptr;
    if(instance == nullptr) {
        instance = new REOBSServiceConfig();
    }
    return instance;
}

REOBSServiceConfig::REOBSServiceConfig() {
    
}

bool REOBSServiceConfig::initService()
{
    if (_loadService())
        return true;

    service = obs_service_create("rtmp_common", "default_service", nullptr,
                     nullptr);
    if (!service)
        return false;
    obs_service_release(service);

    return true;
}

obs_service_t* REOBSServiceConfig::getService() {
    if (!service) {
        service = obs_service_create("rtmp_common", NULL, NULL, nullptr);
        obs_service_release(service);
    }
    return service;
}

void REOBSServiceConfig::saveCustomService(const char* server, const char *key, bool isNeedAuthorization, const char* username, const char *password) {
    this->_saveService(true, nullptr, server, key, isNeedAuthorization, username, password);
}

void REOBSServiceConfig::saveDefaultService(const char* serviceName, const char* server, const char *key) {
    this->_saveService(false, serviceName, server, key, false, nullptr, nullptr);
}

void REOBSServiceConfig::_saveService(bool isCustom, const char*serviceName, const char* server, const char *key, bool isNeedAuthorization, const char* username, const char *password) {
//    "settings": {
//        "bwtest": false,
//        "key": "test",//串流密钥
//        "server": "rtmp://47.93.202.254/hls",//服务器地址
//        "use_auth": false,
//        "username": "***",
//        "password": "****"
//    },
//    "type": "rtmp_custom" //_saveService() 函数中使用 service_id 设置
    const char *service_id = isCustom ? "rtmp_custom" : "rtmp_common";

    obs_service_t *oldService = getService();
    OBSData hotkeyData = obs_hotkeys_save_service(oldService);
    obs_data_release(hotkeyData);

    OBSData settings = obs_data_create();
    obs_data_release(settings);

    if (!isCustom) {
        obs_data_set_string(settings, "service", serviceName);
        obs_data_set_string(settings, "server",server);
    } else {
        obs_data_set_string(settings, "server", server);
        obs_data_set_bool(settings, "use_auth", isNeedAuthorization);
        if (isNeedAuthorization) {
            obs_data_set_string(
                settings, "username", username);
            obs_data_set_string(settings, "password", password);
        }
    }

    obs_data_set_bool(settings, "bwtest", false);

    obs_data_set_string(settings, "key", key);

    OBSService newService = obs_service_create(
        service_id, "default_service", settings, nullptr);
    obs_service_release(newService);

    if (!newService)
        return;

    _setService(newService);
    
    //保存 service
    _saveService();
    
//    auth = auth;
//    if (!!main->auth)
//        main->auth->LoadUI();
}

void REOBSServiceConfig::_setService(obs_service_t *newService) {
    if (newService)
        service = newService;
}


void REOBSServiceConfig::_saveService() {
    if(!service) {
        return ;
    }
    char dirPath[512];
    int ret = REOBSCommon::getProfilePath(dirPath, sizeof(dirPath));
    if (ret <= 0)
        return ;
    
    char serviceJsonPath[512];
    sprintf(serviceJsonPath, "%s/%s", dirPath, SERVICE_CONFIG_NAME);

    obs_data_t *data = obs_data_create();
    obs_data_t *settings = obs_service_get_settings(service);

    obs_data_set_string(data, "type", obs_service_get_type(service));
    obs_data_set_obj(data, "settings", settings);

    if (!obs_data_save_json_safe(data, serviceJsonPath, "tmp", "bak"))
        blog(LOG_WARNING, "Failed to save service");

    obs_data_release(settings);
    obs_data_release(data);
}

bool REOBSServiceConfig::_loadService() {
    const char *type;

    char dirPath[500];
    int ret = REOBSCommon::getProfilePath(dirPath, sizeof(dirPath));
    if (ret <= 0)
        return false;
    
    char serviceJsonPath[512];
    sprintf(serviceJsonPath, "%s/%s", dirPath, SERVICE_CONFIG_NAME);
    
    if(!os_file_exists(serviceJsonPath)) {
        if(!config_create(serviceJsonPath)) {
            return false;
        }
    }

    obs_data_t *data = obs_data_create_from_json_file_safe(serviceJsonPath, "bak");

    if (!data)
        return false;

    obs_data_set_default_string(data, "type", "rtmp_common");
    type = obs_data_get_string(data, "type");

    obs_data_t *settings = obs_data_get_obj(data, "settings");
    obs_data_t *hotkey_data = obs_data_get_obj(data, "hotkeys");

    service = obs_service_create(type, "default_service", settings,
                     hotkey_data);
    obs_service_release(service);

    obs_data_release(hotkey_data);
    obs_data_release(settings);
    obs_data_release(data);

    return !!service;
}
    
//int REOBSServiceConfig::getProfilePath(char *path, int size)
//{
//    //TODO: obs-test 最好能获取 appName 的系统API来代替
//    char server_cfg_path[512];
//    int result = os_get_config_path(server_cfg_path, sizeof(server_cfg_path), APP_CONFIG_PATH);
//    
//    if(result < 0) {
//        blog(LOG_DEBUG, "fail to get config path");
//        return -1;
//    }
//
//    if (os_mkdirs(server_cfg_path) == MKDIR_ERROR) {
//        return -1;
//    }
//
//    return snprintf(path, 512, "%s", server_cfg_path);
////    return sprintf(path, "%s", server_cfg_path);
//}


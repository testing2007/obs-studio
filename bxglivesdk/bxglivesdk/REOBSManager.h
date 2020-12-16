//
//  REOBSManager.hpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/3.
//

#ifndef REOBSManagerImpl_hpp
#define REOBSManagerImpl_hpp

#include <stdio.h>
//
#include <util/base.h>
#include "obs.hpp" //包含了 obs.h

using namespace std;

class REOBSManager {
public:
    static REOBSManager* share();
    
    //初始化 OBS
    bool _initOBS();
    
    //设置推流窗口
    void setContentView(id view);

    //释放内存
    void terminal();

    //开始录制+推流
    void startRecord();

    //停止录制+推流
    void stopRecord();
    
    //开始推流
    void startPushStream();

    //停止推流
    void stopPushStream();
    
private:
    void _initAV();
    void _createDisplay(id view);
    
private:
    
    REOBSManager();
    ~REOBSManager() {};
    REOBSManager(const REOBSManager&) = delete;
    REOBSManager& operator=(const REOBSManager&) = delete;
    
private:
    OBSDisplay display;
    OBSScene scene;
    OBSEncoder h264Recording;
    OBSEncoder aacRecording;

    OBSOutput fileOutput;

    OBSService streamService;
    OBSOutput streamOutput;
};

#define REOBSInstance  (REOBSManager::share())

#endif /* REOBSManagerImpl_hpp */

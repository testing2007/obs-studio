//
//  REOBSManager.hpp
//  obs-test
//
//  Created by ZhiQiang wei on 2020/12/3.
//

#ifndef REOBSManagerImpl_hpp
#define REOBSManagerImpl_hpp

#include <stdio.h>
#include <string>
#include <util/base.h>
#include "obs.hpp" //包含了 obs.h

using namespace std;

class REOBSManager {
public:
    static REOBSManager* share();
    
    //设置推流窗口
    void setContentView(id view);

    //释放内存
    void terminal();

    //开始录制+推流
    void startRecord();

    //停止录制+推流
    void stopRecord();

private:
    void initOBS();
    void createDisplay(id view);
    
private:
    
    REOBSManager();
    ~REOBSManager() {};
    REOBSManager(const REOBSManager&);
    REOBSManager& operator=(const REOBSManager&);
    
private:
    OBSDisplay display;
    OBSScene scene;
    OBSEncoder h264Recording;
    OBSEncoder aacRecording;

    OBSOutput fileOutput;

    OBSService streamService;
    OBSOutput streamOutput;
};

#define OBSInstance  (REOBSManager::share())

#endif /* REOBSManagerImpl_hpp */

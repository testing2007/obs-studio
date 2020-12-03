//
//  REOBSManager.h
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/16.
//

#ifndef REOBSManager_H
#define REOBSManager_H

#undef DECLARE_DELETER
#import <AppKit/AppKit.h>

@interface REOBSManager : NSObject
+ (instancetype)share;

//设置推流窗口
- (void)setContentView:(id)view;

//释放内存
- (void)terminal;

//开始录制+推流
- (void)startRecord;

//停止录制+推流
- (void)stopRecord;

@end

#endif /* REOBSManager_H */

//
//  REOBSMainVC.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/19.
//

#import "REOBSMainVC.h"
#import "REOBSManager.h"

@interface REOBSMainVC ()<NSWindowDelegate>
@property (weak) IBOutlet NSView *contentView;
@property (nonatomic, assign) bool bRecording;
@property (weak) IBOutlet NSButton *btnRecord;

@property (nonatomic, assign) bool bPushStream;
@property (weak) IBOutlet NSButton *btnPushStream;

@end

@implementation REOBSMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.btnRecord setTitle:@"开始录制"];
    OBSInstance->setContentView(self.contentView);
}

- (BOOL)isActive {
    return _bPushStream || _bRecording;
}

- (IBAction)onRecord:(id)sender {
    if(_bRecording) {
        OBSInstance->stopRecord();
        self.bRecording = !_bRecording;
    } else {
        if(![self isActive]) {
            OBSInstance->startRecord();
            self.bRecording = !_bRecording;
        } else {
            blog(LOG_INFO, "开启新的链路之前请先关闭现有的链路");
        }
    }
}

- (void)setBRecording:(bool)bRecording {
    if(bRecording) {
        [self.btnRecord setTitle:@"正在录制"];
    } else {
        [self.btnRecord setTitle:@"开始录制"];
    }
    _bRecording = bRecording;
}

- (IBAction)onStreamRecord:(id)sender {
    if(_bPushStream) {
        OBSInstance->stopPushStream();
        self.bPushStream = !_bPushStream;
    } else {
        if(![self isActive]) {
            OBSInstance->startPushStream();
            self.bPushStream = !_bPushStream;
        } else {
            blog(LOG_INFO, "开启新的链路之前请先关闭现有的链路");
        }
    }
}

- (void)setBPushStream:(bool)bPushStream {
    if(bPushStream) {
        [self.btnPushStream setTitle:@"正在推流"];
    } else {
        [self.btnPushStream setTitle:@"开始推流"];
    }
    _bPushStream = bPushStream;
}

-(void)windowWillClose:(NSNotification *)notification {
    OBSInstance->terminal();
}
@end

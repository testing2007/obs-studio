//
//  REOBSMainVC.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/19.
//

#import "REOBSMainVC.h"
#import "REOBS.h"

@interface REOBSMainVC ()
@property (weak) IBOutlet NSView *contentView;
@property (nonatomic, assign) bool bRecording;
@property (weak) IBOutlet NSButton *btnRecord;

@property (nonatomic, assign) bool bPushStream;
@property (weak) IBOutlet NSButton *btnPushStream;

@property (weak) IBOutlet NSTextField *liveTxtField;
@property (weak) IBOutlet NSPopUpButton *popFormatBtn;
@property (weak) IBOutlet NSPopUpButton *popVBitrateBtn;

@end

@implementation REOBSMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.btnRecord setTitle:@"开始录制"];
    REOBSManagerInstance->setContentView(self.contentView);
    
//    const vector<REOBSFormatDesc>& formats = REOBSManagerInstance->getFormats();
//    blog(LOG_DEBUG, "11");
}

- (BOOL)isActive {
    return _bPushStream || _bRecording;
}

- (IBAction)onRecord:(id)sender {
    if(_bRecording) {
        REOBSManagerInstance->stopRecord();
        self.bRecording = !_bRecording;
    } else {
        if(![self isActive]) {
            REOBSManagerInstance->startRecord();
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
        REOBSManagerInstance->stopPushStream();
        self.bPushStream = !_bPushStream;
    } else {
        if(![self isActive]) {
            REOBSManagerInstance->startPushStream();
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
    REOBSManagerInstance->terminal();
}






@end

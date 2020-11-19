//
//  REOBSMainVC.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/19.
//

#import "REOBSMainVC.h"
#import "REOBSManager.h"

@interface REOBSMainVC ()
@property (weak) IBOutlet NSView *contentView;
@property (nonatomic, assign) bool bRecording;
@property (weak) IBOutlet NSButton *btnRecord;
@end

@implementation REOBSMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.btnRecord setTitle:@"开始录制"];
    [[REOBSManager share] setContentView:self.contentView];

}

- (IBAction)onRecord:(id)sender {
    if(_bRecording) {
        [[REOBSManager share] stopRecord];
    } else {
        [[REOBSManager share] startRecord];
    }
    self.bRecording = !_bRecording;
}

- (void)setBRecording:(bool)bRecording {
    if(bRecording) {
        [self.btnRecord setTitle:@"正在录制"];
    } else {
        [self.btnRecord setTitle:@"开始录制"];
    }
    _bRecording = bRecording;
}

@end

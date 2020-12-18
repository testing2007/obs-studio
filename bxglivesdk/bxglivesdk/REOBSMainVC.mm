//
//  REOBSMainVC.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/19.
//

#import "REOBSMainVC.h"
#import "REOBS.h"

@interface REOBSMainVC ()<NSMenuDelegate> {
    const vector<REOBSFormatDesc> *formats;
}

@property (weak) IBOutlet NSTextField *liveTxt;
@property (weak) IBOutlet NSButton *hlsCheckBtn;
@property (weak) IBOutlet NSButton *rtmpCheckBtn;
@property (weak) IBOutlet NSButton *cpAddrBtn;

@property (weak) IBOutlet NSPopUpButton *formatBtn;
@property (weak) IBOutlet NSPopUpButton *vBitrateBtn;
@property (weak) IBOutlet NSPopUpButton *vGOPBtn;
@property (weak) IBOutlet NSPopUpButton *videoCodecBtn;
@property (weak) IBOutlet NSTextField *videoCodecParamTxt;
@property (weak) IBOutlet NSPopUpButton *aBitrateBtn;
//6个音轨
@property (weak) IBOutlet NSButton *aCheckBtn1;
@property (weak) IBOutlet NSButton *aCheckBtn2;
@property (weak) IBOutlet NSButton *aCheckBtn3;
@property (weak) IBOutlet NSButton *aCheckBtn4;
@property (weak) IBOutlet NSButton *aCheckBtn5;
@property (weak) IBOutlet NSButton *aCheckBtn6;

@property (weak) IBOutlet NSPopUpButton *audioCodecBtn;
@property (weak) IBOutlet NSTextField *audioCodecParamTxt;

///
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
    REOBSManagerInstance->setContentView(self.contentView);

    [self resetCtrl];
    [self loadData];
}



- (void)onChangeFormat:(NSObject*)format {
    NSAssert([format isKindOfClass:[NSMenuItem class]], @"menu item is not a NSMenuItem type");
    NSMenuItem *menuItem = (NSMenuItem*)format;
    NSLog(@"onChangeFormat %@", menuItem.keyEquivalent);
    const REOBSFormatDesc &formatDesc = (*formats)[menuItem.keyEquivalent.intValue];
    [self changeFormat:formatDesc];
}

- (void)onChangeVideoCodec:(NSObject*)vCodec {
    
}

- (void)onChangeAudioCodec:(NSObject*)aCodec {
    
}

-(void)fillFormatsCtrl {
    int i=0;
    for(vector<REOBSFormatDesc>::const_iterator iter = formats->begin(); iter!= formats->end(); ++iter) {
        REOBSFormatDesc item = (*iter);
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@(item.name) action:@selector(onChangeFormat:) keyEquivalent:@(i).stringValue];
        [self.formatBtn.cell.menu addItem:menuItem];
        i++;
    }
}

-(void)fillVideoCodecsCtrl:(vector<REOBSCodecDesc>&)vCodecDesc {
    int i=0;
    for(vector<REOBSCodecDesc>::const_iterator codecIter = vCodecDesc.begin(); codecIter!= vCodecDesc.end(); ++codecIter) {
        REOBSCodecDesc item = (*codecIter);
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@(item.name) action:@selector(onChangeVideoCodec:) keyEquivalent:@(i).stringValue];
        if(item.isDefaultCodec) {
            [self.videoCodecBtn selectItemAtIndex:i];
        }
        [self.videoCodecBtn.cell.menu addItem:menuItem];
        i++;
    }
}

-(void)fillAudioCodecsCtrl:(vector<REOBSCodecDesc>&)aCodecDesc {
    int i=0;
    for(vector<REOBSCodecDesc>::const_iterator codecIter = aCodecDesc.begin(); codecIter!= aCodecDesc.end(); ++codecIter) {
        REOBSCodecDesc item = (*codecIter);
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@(item.name) action:@selector(onChangeAudioCodec:) keyEquivalent:@(i).stringValue];
        if(item.isDefaultCodec) {
            [self.audioCodecBtn selectItemAtIndex:i];
        }
        [self.audioCodecBtn.cell.menu addItem:menuItem];
        i++;
    }
}

-(void)changeFormat:(const REOBSFormatDesc&)newFormat {
    [self.videoCodecBtn removeAllItems];
    [self.audioCodecBtn removeAllItems];
    
    vector<REOBSCodecDesc> vCodecDesc;
    vector<REOBSCodecDesc> aCodecDesc;
    REOBSManagerInstance->reloadCodecs(newFormat.desc, vCodecDesc, aCodecDesc);
    [self fillVideoCodecsCtrl:vCodecDesc];
    [self fillAudioCodecsCtrl:aCodecDesc];
}

-(void)loadData {
    const char* url = REOBSBasicConfigInstance->getOutputURL();
    [self.liveTxt.cell setTitle:@(url)];

    self->formats = &(REOBSManagerInstance->getFormats());
    [self fillFormatsCtrl];
    
    //TODO:需要根据配置文件的记录显示
    if(formats->size()>0) {
        [self.formatBtn selectItemAtIndex:0];
        const REOBSFormatDesc &selectFormat = (*formats)[0];
        [self changeFormat:selectFormat];
    } else {
//        [self ctrlByNonFormat];
    }
}

-(void)loadFormatToFormatCtrl {
    
}

-(void)resetCtrl {
    [self.formatBtn removeAllItems];
    [self.vBitrateBtn removeAllItems];
    [self.vGOPBtn removeAllItems];
    [self.videoCodecBtn removeAllItems];
    const char* vCodecParams = REOBSBasicConfigInstance->getOutputVideoCodecParam();
    [self.videoCodecParamTxt.cell setTitle:@(vCodecParams)];
    [self.aBitrateBtn removeAllItems];
    [self.aCheckBtn1.cell setEnabled:TRUE];
    [self.aCheckBtn2.cell setEnabled:FALSE];
    [self.aCheckBtn3.cell setEnabled:FALSE];
    [self.aCheckBtn4.cell setEnabled:FALSE];
    [self.aCheckBtn5.cell setEnabled:FALSE];
    [self.aCheckBtn6.cell setEnabled:FALSE];
    [self.audioCodecBtn removeAllItems];
    const char* aCodecParams = REOBSBasicConfigInstance->getOutputAudioCodecParam();
    [self.audioCodecParamTxt.cell setTitle:@(aCodecParams)];
}

//- (BOOL)menu:(NSMenu*)menu updateItem:(NSMenuItem*)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel {
//    NSLog(@"shouldCancel= %@", shouldCancel ? @"true" : @"false");
//    return true;
//}
////- (void)menuDidClose:(NSMenu *)menu API_AVAILABLE(macos(10.5)) {
////    NSLog(@"menuDidClose %@", menu);
////}

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

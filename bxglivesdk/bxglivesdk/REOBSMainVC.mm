//
//  REOBSMainVC.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/19.
//

#import "REOBSMainVC.h"
#import "REOBS.h"

const char* HLS_URL = "rtmp://47.93.202.254/rtmp"; //m3u8/ts 网页查看， test 为密钥
const char* RMTP_URL = "rtmp://47.93.202.254/rtmp/test"; //rtmp录像形式

@interface REOBSMainVC ()<NSMenuDelegate> {
    const vector<REOBSFormatDesc> *formats;
    vector<REOBSCodecDesc> vCodecDesc;
    vector<REOBSCodecDesc> aCodecDesc;

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


@property (nonatomic, assign) int selVideoCodecIndex;
@property (nonatomic, assign) int selAudioCodecIndex;

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
    if(menuItem.keyEquivalent.length > 0) {
        const REOBSFormatDesc &formatDesc = (*formats)[menuItem.keyEquivalent.intValue];
        [self changeFormat:formatDesc];
    }
}

- (void)onChangeVideoCodec:(NSObject*)vCodec {
//    self.video
//    self.vCodecDesc[self.selVideoCodecIndex]
    NSString* strIndex = (NSString*)(vCodec);
    self.selVideoCodecIndex = strIndex.intValue;
    [self.videoCodecBtn selectItemAtIndex:self.selVideoCodecIndex];
    REOBSCodecDesc &selCodec = self->vCodecDesc[self.selVideoCodecIndex];
    REOBSBasicConfigInstance->setOutputVideoCodec(selCodec.desc);
}

- (void)onChangeAudioCodec:(NSObject*)aCodec {
    NSString* strIndex = (NSString*)(aCodec);
    self.selVideoCodecIndex = strIndex.intValue;
    [self.videoCodecBtn selectItemAtIndex:self.selVideoCodecIndex];
    REOBSCodecDesc &selCodec = self->aCodecDesc[self.selVideoCodecIndex];
    REOBSBasicConfigInstance->setOutputAudioCodec(selCodec.desc);
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
    int selCodecIndex = -1;
    int64_t selCodecId = REOBSBasicConfigInstance->getOutputVideoCodecId();
    for(vector<REOBSCodecDesc>::const_iterator codecIter = vCodecDesc.begin(); codecIter!= vCodecDesc.end(); ++codecIter) {
        REOBSCodecDesc item = (*codecIter);
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@(item.name) action:@selector(onChangeVideoCodec:) keyEquivalent:@(i).stringValue];
        if(selCodecId != 0) {
            selCodecIndex = i;
        } else if(item.isDefaultCodec){
            selCodecIndex = i;
        }
        
        [self.videoCodecBtn.cell.menu addItem:menuItem];
        i++;
    }
    if(selCodecIndex!=-1) {
        [self.videoCodecBtn selectItemAtIndex:selCodecIndex];
    }
    self.selVideoCodecIndex = selCodecIndex;
}

-(void)fillAudioCodecsCtrl:(vector<REOBSCodecDesc>&)aCodecDesc {
    int i=0;
    int selCodecIndex = -1;
    int64_t selCodecId = REOBSBasicConfigInstance->getOutputVideoCodecId();
    for(vector<REOBSCodecDesc>::const_iterator codecIter = aCodecDesc.begin(); codecIter!= aCodecDesc.end(); ++codecIter) {
        REOBSCodecDesc item = (*codecIter);
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@(item.name) action:@selector(onChangeAudioCodec:) keyEquivalent:@(i).stringValue];
        if(selCodecId != 0) {
            selCodecIndex = i;
        } else if(item.isDefaultCodec){
            selCodecIndex = i;
        }
        [self.audioCodecBtn.cell.menu addItem:menuItem];
        i++;
    }
    
    if(selCodecIndex!=0) {
        [self.audioCodecBtn selectItemAtIndex:selCodecIndex];
    }
    self.selAudioCodecIndex = selCodecIndex;
}

-(void)changeFormat:(const REOBSFormatDesc&)newFormat {
    [self.videoCodecBtn removeAllItems];
    [self.audioCodecBtn removeAllItems];
    self->vCodecDesc.clear();
    self->aCodecDesc.clear();

    int videoCodecIndex;
    int audioCodecIndex;
    REOBSManagerInstance->reloadCodecs(newFormat.desc, self->vCodecDesc, videoCodecIndex, self->aCodecDesc, audioCodecIndex);

    //填充音视频控件值 TODO:step value
    int videoBitrate = REOBSBasicConfigInstance->getOutputVideoBitrate();
    [self.videoCodecBtn setTitle:@(videoBitrate).stringValue];
    int gop = REOBSBasicConfigInstance->getOutputVideoGOPSize();
    [self.vGOPBtn setTitle:@(gop).stringValue];
    [self fillVideoCodecsCtrl:vCodecDesc];

    const char* vCodecParams = REOBSBasicConfigInstance->getOutputVideoCodecParam();
    [self.videoCodecParamTxt.cell setTitle:@(vCodecParams)];
    
    int audioBitrate = REOBSBasicConfigInstance->getOutputAudioBitrate();
    [self.audioCodecBtn setTitle:@(audioBitrate).stringValue];
    int audioMixes = REOBSBasicConfigInstance->getOutputAudioMixes();
    [self.aCheckBtn1 setState:(audioMixes & (1 << 0)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn2 setState:(audioMixes & (1 << 1)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn3 setState:(audioMixes & (1 << 2)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn4 setState:(audioMixes & (1 << 3)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn5 setState:(audioMixes & (1 << 4)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn6 setState:(audioMixes & (1 << 5)) ? NSControlStateValueOn : NSControlStateValueOff ];
    
    [self fillAudioCodecsCtrl:aCodecDesc];

    const char* aCodecParams = REOBSBasicConfigInstance->getOutputAudioCodecParam();
    [self.audioCodecParamTxt.cell setTitle:@(aCodecParams)];

    //禁用/启用视频相关控件
    [self.vBitrateBtn setEnabled:videoCodecIndex == -1 ? false : true];
    [self.vGOPBtn setEnabled:videoCodecIndex == -1 ? false : true];
    [self.videoCodecBtn setEnabled:videoCodecIndex == -1 ? false : true];
    [self.videoCodecParamTxt setEnabled:videoCodecIndex == -1 ? false : true];

    //禁用/启用音频相关控件
    [self.aBitrateBtn setEnabled:audioCodecIndex == -1 ? false : true];
    [self.aCheckBtn1 setEnabled:audioCodecIndex == -1 ? false : true];
    [self.aCheckBtn2 setEnabled:audioCodecIndex == -1 ? false : true];
    [self.aCheckBtn3 setEnabled:audioCodecIndex == -1 ? false : true];
    [self.aCheckBtn4 setEnabled:audioCodecIndex == -1 ? false : true];
    [self.aCheckBtn5 setEnabled:audioCodecIndex == -1 ? false : true];
    [self.aCheckBtn6 setEnabled:audioCodecIndex == -1 ? false : true];
    [self.audioCodecBtn setEnabled:audioCodecIndex == -1 ? false : true];
    [self.audioCodecParamTxt setEnabled:audioCodecIndex == -1 ? false : true];
}

-(void)loadData {
    const char* url = REOBSBasicConfigInstance->getOutputURL();
    
    if(::strcmp(url, RMTP_URL) == 0 || url==NULL || ::strlen(url)==0) {
        [self checkRTMP];
    } else {
        [self checkHLS];
    }
    
    int lastSelIndex;
    self->formats = &(REOBSManagerInstance->getFormats(lastSelIndex));
    [self fillFormatsCtrl];

    int formatsSize = formats->size();
    if(formatsSize>0) {
        if(lastSelIndex != -1 && lastSelIndex<formatsSize) {
            [self.formatBtn selectItemAtIndex:lastSelIndex];
        } else {
            lastSelIndex = 0;
            [self.formatBtn selectItemAtIndex:lastSelIndex];
        }
        const REOBSFormatDesc &selectFormat = (*formats)[lastSelIndex];
        [self changeFormat:selectFormat];
    } else {
//        [self ctrlByNonFormat];
    }
    
}

- (void)checkHLS {
    [self.hlsCheckBtn setState:NSControlStateValueOn];
    [self.liveTxt.cell setTitle:@(HLS_URL)];
    [self.rtmpCheckBtn setState:NSControlStateValueOff];
}

- (void)checkRTMP {
    [self.rtmpCheckBtn setState:NSControlStateValueOn];
    [self.liveTxt.cell setTitle:@(RMTP_URL)];
    [self.hlsCheckBtn setState:NSControlStateValueOff];
}

- (void)onHLS:(NSButton*)hlsObj {
    [self checkHLS];
}

- (void)onRTMP:(NSButton*)rtmpObj {
    [self checkRTMP];
}

-(void)resetCtrl {
    [self.liveTxt.cell setTitle:@""];
    [self.liveTxt.cell setEnabled:false];//禁用
    
    [self.hlsCheckBtn setAction:@selector(onHLS:)];
    [self.rtmpCheckBtn setAction:@selector(onRTMP:)];
    
    [self.hlsCheckBtn setState:NSControlStateValueOff];
    [self.rtmpCheckBtn setState:NSControlStateValueOff];
    
    [self.formatBtn removeAllItems];
    [self.vBitrateBtn removeAllItems];
    [self.vGOPBtn removeAllItems];
    [self.videoCodecBtn removeAllItems];
    [self.videoCodecParamTxt.cell setTitle:@""];
    [self.aBitrateBtn removeAllItems];
    
    [self.aCheckBtn1.cell setEnabled:TRUE];
    self.aCheckBtn1.tag = 1;
    [self.aCheckBtn1 setAction:@selector(onCheckBtn:)];
    [self.aCheckBtn2.cell setEnabled:TRUE];
    self.aCheckBtn1.tag = 2;
    [self.aCheckBtn1 setAction:@selector(onCheckBtn:)];
    [self.aCheckBtn3.cell setEnabled:TRUE];
    self.aCheckBtn1.tag = 3;
    [self.aCheckBtn1 setAction:@selector(onCheckBtn:)];
    [self.aCheckBtn4.cell setEnabled:TRUE];
    self.aCheckBtn1.tag = 4;
    [self.aCheckBtn1 setAction:@selector(onCheckBtn:)];
    [self.aCheckBtn5.cell setEnabled:TRUE];
    self.aCheckBtn1.tag = 5;
    [self.aCheckBtn1 setAction:@selector(onCheckBtn:)];
    [self.aCheckBtn6.cell setEnabled:TRUE];
    self.aCheckBtn1.tag = 6;
    [self.aCheckBtn1 setAction:@selector(onCheckBtn:)];

    [self.audioCodecBtn removeAllItems];
    [self.audioCodecParamTxt.cell setTitle:@""];
}

- (IBAction)onConfirm:(id)sender {
    NSString *strURL = (NSString*)(self.liveTxt.cell.title);
    REOBSBasicConfigInstance->setOutputURL(strURL.UTF8String);
    
    const struct ff_format_desc * format = REOBSManagerInstance->getCurFormatDesc();
    REOBSBasicConfigInstance->setOutputFormat(format);
    
    NSString *strVBitrate = self.vBitrateBtn.title;
    if(strVBitrate) {
        REOBSBasicConfigInstance->setOutputVideoBitrate(strVBitrate.intValue);
    }
    NSString *strVGOPSize = self.vGOPBtn.title;
    if(strVGOPSize) {
        REOBSBasicConfigInstance->setOutputVideoGOPSize(strVGOPSize.intValue);
    }
    
    
//    REOBSBasicConfigInstance->setOutputVideoCodec(<#int codecId#>, <#const char *codecName#>)
    


    NSString *strVCodecParam = self.videoCodecParamTxt.cell.title;
    if(strVCodecParam) {
        REOBSBasicConfigInstance->setOutputVideoCodecParam(strVCodecParam.UTF8String);
    }
    
    int audioMixes = 0;
    if(self.aCheckBtn1.state == NSControlStateValueOn) {
        audioMixes += (1 << 0);
    }
    if(self.aCheckBtn2.state == NSControlStateValueOn) {
        audioMixes += (1 << 1);
    }
    if(self.aCheckBtn3.state == NSControlStateValueOn) {
        audioMixes += (1 << 2);
    }
    if(self.aCheckBtn4.state == NSControlStateValueOn) {
        audioMixes += (1 << 3);
    }
    if(self.aCheckBtn5.state == NSControlStateValueOn) {
        audioMixes += (1 << 4);
    }
    if(self.aCheckBtn6.state == NSControlStateValueOn) {
        audioMixes += (1 << 5);
    }
    REOBSBasicConfigInstance->setOutputAudioMixes(audioMixes);
    
    

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

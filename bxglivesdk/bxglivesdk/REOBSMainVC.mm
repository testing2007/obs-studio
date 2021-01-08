//
//  REOBSMainVC.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/19.
//

#import "REOBSMainVC.h"
#import "REOBS.h"

const char* HLS_URL = "rtmp://47.93.202.254/rtmp"; //m3u8/ts 网页查看， test 为密钥
//const char* RMTP_URL = "rtmp://47.93.202.254/hls/test"; //rtmp录像形式
const char* RMTP_URL = "rtmp://localhost/hls/test"; //rtmp录像形式

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
    self.aCheckBtn2.tag = 2;
    [self.aCheckBtn2 setAction:@selector(onCheckBtn:)];
    [self.aCheckBtn3.cell setEnabled:TRUE];
    self.aCheckBtn3.tag = 3;
    [self.aCheckBtn3 setAction:@selector(onCheckBtn:)];
    [self.aCheckBtn4.cell setEnabled:TRUE];
    self.aCheckBtn4.tag = 4;
    [self.aCheckBtn4 setAction:@selector(onCheckBtn:)];
    [self.aCheckBtn5.cell setEnabled:TRUE];
    self.aCheckBtn5.tag = 5;
    [self.aCheckBtn5 setAction:@selector(onCheckBtn:)];
    [self.aCheckBtn6.cell setEnabled:TRUE];
    self.aCheckBtn6.tag = 6;
    [self.aCheckBtn6 setAction:@selector(onCheckBtn:)];

    [self.audioCodecBtn removeAllItems];
    [self.audioCodecParamTxt.cell setTitle:@""];
    
    
    //初始化数据
//    FFURL=rtmp://47.93.202.254/hls/test
//    FFFormat=hls
//    FFFormatMimeType=
//    FFExtension=m3u8
//    FFVBitrate=128
//    FFVGOPSize=90
//    FFVEncoderId=27
//    FFVEncoder=libx264
//    FFVCustom=tune=zerolatency
//    FFABitrate=96
//    FFAudioMixes=0
//    FFAEncoderId=86018
//    FFAEncoder=aac
//    FFACustom=
    
    [self checkRTMP];
    const char* format = REOBSBasicConfigInstance->getOutputFormat();
    NSMenuItem *formatMenuItem = [[NSMenuItem alloc] initWithTitle:format==nullptr ? @("hls") : @(format) action:nil keyEquivalent:@("0")];
    if(format == nullptr) {
        REOBSBasicConfigInstance->setOutputFormat("hls", nullptr, "m3u8");
    }
    [self.formatBtn.cell.menu addItem:formatMenuItem];
    
    NSInteger nVBitrate = REOBSBasicConfigInstance->getOutputVideoBitrate();
    NSMenuItem *vBitrateMenuItem = [[NSMenuItem alloc] initWithTitle:nVBitrate==0 ? @("128") : @(nVBitrate).stringValue action:nil keyEquivalent:@("0")];
    [self.vBitrateBtn.cell.menu addItem:vBitrateMenuItem];
    
    NSInteger nGOPSize = REOBSBasicConfigInstance->getOutputVideoGOPSize();
    NSMenuItem *vGOPMenuItem = [[NSMenuItem alloc] initWithTitle:nGOPSize==0 ? @("90") : @(nGOPSize).stringValue action:nil keyEquivalent:@("0")];
    [self.vGOPBtn.cell.menu addItem:vGOPMenuItem];

    const char* vCodecName = REOBSBasicConfigInstance->getOutputVideoCodecName();
    NSMenuItem *vCodecMenuItem = [[NSMenuItem alloc] initWithTitle:vCodecName==nullptr ? @("libx264") : @(vCodecName) action:nil keyEquivalent:@("0")];
    if(vCodecName == nullptr) {
        REOBSBasicConfigInstance->setOutputVideoCodec(27, "libx264");
    }
    [self.videoCodecBtn.cell.menu addItem:vCodecMenuItem];
    
    const char* vCodecParams = REOBSBasicConfigInstance->getOutputVideoCodecParam();
    [self.videoCodecParamTxt.cell setTitle:vCodecParams==nullptr ? @"tune=zerolatency" : @(vCodecParams)];
    NSInteger nABitrate = REOBSBasicConfigInstance->getOutputAudioBitrate();
    NSMenuItem *aBitrateMenuItem = [[NSMenuItem alloc] initWithTitle:nABitrate==0 ? @("96") : @(nABitrate).stringValue action:nil keyEquivalent:@("0")];
    [self.aBitrateBtn.cell.menu addItem:aBitrateMenuItem];

    NSInteger audioMixes = REOBSBasicConfigInstance->getOutputAudioMixes();
    [self.aCheckBtn1 setState:(audioMixes & (1 << 0)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn2 setState:(audioMixes & (1 << 1)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn3 setState:(audioMixes & (1 << 2)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn4 setState:(audioMixes & (1 << 3)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn5 setState:(audioMixes & (1 << 4)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn6 setState:(audioMixes & (1 << 5)) ? NSControlStateValueOn : NSControlStateValueOff ];

    const char* aCodecName = REOBSBasicConfigInstance->getOutputAudioCodecName();
    NSMenuItem *aCodecMenuItem = [[NSMenuItem alloc] initWithTitle:aCodecName==nullptr ? @("aac") : @(aCodecName) action:nil keyEquivalent:@("0")];
    if(aCodecName == nullptr) {
        REOBSBasicConfigInstance->setOutputAudioCodec(86018, "aac");
    }
    [self.audioCodecBtn.cell.menu addItem:aCodecMenuItem];

    const char* aCodecParams = REOBSBasicConfigInstance->getOutputAudioCodecParam();
    [self.audioCodecParamTxt.cell setTitle:vCodecParams==nullptr ? @"" : @(aCodecParams)];
}

-(void)loadData {
    const char* url = REOBSBasicConfigInstance->getOutputURL();
    
    if(url==NULL || astrcmpi(url, RMTP_URL) == 0) {
        [self checkRTMP];
        if(url==NULL) {
            REOBSBasicConfigInstance->setOutputURL(RMTP_URL);
        }
    } else {
        [self checkHLS];
    }
    
    int lastSelIndex;
    self->formats = &(REOBSManagerInstance->getFormats(lastSelIndex));
    [self fillFormatsCtrl];

    NSInteger formatsSize = formats->size();
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
        [self disalbeSettingCtrl];
    }
}

- (void)disalbeSettingCtrl {
    [self.liveTxt.cell setEnabled:false];
    
    [self.hlsCheckBtn setEnabled:false];
    [self.rtmpCheckBtn setEnabled:false];
    
    [self.formatBtn setEnabled:false];
    [self.vBitrateBtn setEnabled:false];
    [self.vGOPBtn setEnabled:false];
    [self.videoCodecBtn setEnabled:false];
    [self.videoCodecParamTxt setEnabled:false];
    [self.aBitrateBtn setEnabled:false];
    
    [self.aCheckBtn1 setEnabled:false];
    [self.aCheckBtn2 setEnabled:false];
    [self.aCheckBtn3 setEnabled:false];
    [self.aCheckBtn4 setEnabled:false];
    [self.aCheckBtn5 setEnabled:false];
    [self.aCheckBtn6 setEnabled:false];

    [self.audioCodecBtn setEnabled:false];
    [self.audioCodecParamTxt setEnabled:false];
}

-(void)changeFormat:(const REOBSFormatDesc&)newFormat {
    [self.videoCodecBtn removeAllItems];
    [self.audioCodecBtn removeAllItems];
    self->vCodecDesc.clear();
    self->aCodecDesc.clear();

    int defaultVideoCodecIndex;
    int defaultAudioCodecIndex;
    REOBSManagerInstance->reloadCodecs(newFormat.desc, self->vCodecDesc, defaultVideoCodecIndex, self->aCodecDesc, defaultAudioCodecIndex);

    //填充音视频控件值 TODO:step value
    [self fillVideoCodecsCtrl:vCodecDesc];

    [self fillAudioCodecsCtrl:aCodecDesc];


    //禁用/启用视频相关控件
    NSInteger userSelVideoId = REOBSBasicConfigInstance->getOutputVideoCodecId();
    [self.vBitrateBtn setEnabled:defaultVideoCodecIndex == -1 && userSelVideoId==0 ? false : true];
    [self.vGOPBtn setEnabled:defaultVideoCodecIndex == -1  && userSelVideoId==0 ? false : true];
    [self.videoCodecBtn setEnabled:defaultVideoCodecIndex == -1  && userSelVideoId==0 ? false : true];
    [self.videoCodecParamTxt setEnabled:defaultVideoCodecIndex == -1  && userSelVideoId==0 ? false : true];

    //禁用/启用音频相关控件
    NSInteger userSelAudioId = REOBSBasicConfigInstance->getOutputAudioCodecId();
    [self.aBitrateBtn setEnabled:defaultAudioCodecIndex == -1 && userSelAudioId==0 ? false : true];
    [self.aCheckBtn1 setEnabled:defaultAudioCodecIndex == -1 && userSelAudioId==0 ? false : true];
    [self.aCheckBtn2 setEnabled:defaultAudioCodecIndex == -1 && userSelAudioId==0 ? false : true];
    [self.aCheckBtn3 setEnabled:defaultAudioCodecIndex == -1 && userSelAudioId==0 ? false : true];
    [self.aCheckBtn4 setEnabled:defaultAudioCodecIndex == -1 && userSelAudioId==0 ? false : true];
    [self.aCheckBtn5 setEnabled:defaultAudioCodecIndex == -1 && userSelAudioId==0 ? false : true];
    [self.aCheckBtn6 setEnabled:defaultAudioCodecIndex == -1 && userSelAudioId==0 ? false : true];
    [self.audioCodecBtn setEnabled:defaultAudioCodecIndex == -1 && userSelAudioId==0  ? false : true];
    [self.audioCodecParamTxt setEnabled:defaultAudioCodecIndex == -1 && userSelAudioId==0 ? false : true];
}

-(void)fillFormatsCtrl {
    [self.formatBtn removeAllItems];
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
        } else if(item.defaultSelIndex != -1){
            selCodecIndex = item.defaultSelIndex;
        }
        
        [self.videoCodecBtn.cell.menu addItem:menuItem];
        i++;
    }
    if(vCodecDesc.size() > 0) {
        if(selCodecIndex == -1) {
            selCodecIndex = 0;
        }
        [self.videoCodecBtn selectItemAtIndex:selCodecIndex];
    }
    self.selVideoCodecIndex = selCodecIndex;
}

-(void)fillAudioCodecsCtrl:(vector<REOBSCodecDesc>&)aCodecDesc {
    int i=0;
    int selCodecIndex = -1;
    int64_t selCodecId = REOBSBasicConfigInstance->getOutputAudioCodecId();
    for(vector<REOBSCodecDesc>::const_iterator codecIter = aCodecDesc.begin(); codecIter!= aCodecDesc.end(); ++codecIter) {
        REOBSCodecDesc item = (*codecIter);
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@(item.name) action:@selector(onChangeAudioCodec:) keyEquivalent:@(i).stringValue];
        if(selCodecId != 0) {
            selCodecIndex = i;
        } else if(item.defaultSelIndex != -1){
            selCodecIndex = item.defaultSelIndex;
        }
        [self.audioCodecBtn.cell.menu addItem:menuItem];
        i++;
    }
    if(aCodecDesc.size() > 0) {
        if(selCodecIndex == -1) {
            selCodecIndex = 0;
        }
        [self.audioCodecBtn selectItemAtIndex:selCodecIndex];
    }
    self.selAudioCodecIndex = selCodecIndex;
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
    NSString* strIndex = (NSString*)(vCodec);
    self.selVideoCodecIndex = strIndex.intValue;
    [self.videoCodecBtn selectItemAtIndex:self.selVideoCodecIndex];
    REOBSCodecDesc &selCodec = self->vCodecDesc[self.selVideoCodecIndex];
    REOBSBasicConfigInstance->setOutputVideoCodec(selCodec.id, selCodec.name);
}

- (void)onChangeAudioCodec:(NSObject*)aCodec {
    NSString* strIndex = (NSString*)(aCodec);
    self.selAudioCodecIndex = strIndex.intValue;
    [self.audioCodecBtn selectItemAtIndex:self.selAudioCodecIndex];
    REOBSCodecDesc &selCodec = self->aCodecDesc[self.selAudioCodecIndex];
    REOBSBasicConfigInstance->setOutputAudioCodec(selCodec.id, selCodec.name);
}

- (void)onCheckBtn:(NSButton*)obj {
    NSButton *target = obj;
    switch(target.tag) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
            [obj setState: obj.state == NSControlStateValueOn ? NSControlStateValueOff : NSControlStateValueOn];
            break;
        default :
            break;
    }
}

- (void)onHLS:(NSButton*)hlsObj {
    [self checkHLS];
}

- (void)onRTMP:(NSButton*)rtmpObj {
    [self checkRTMP];
}

- (BOOL)isActive {
    return _bPushStream || _bRecording;
}

- (IBAction)onConfirm:(id)sender {
    //设置视频参数
    NSString *strURL = (NSString*)(self.liveTxt.cell.title);
    REOBSBasicConfigInstance->setOutputURL(strURL.UTF8String);
    const struct ff_format_desc * format = REOBSManagerInstance->getCurFormatDesc();
    const char *formatName = format ? ff_format_desc_name(format) : nullptr;
    const char *formatMimeType = format ? ff_format_desc_mime_type(format) : nullptr;
    const char *formatExtension = format ? ff_format_desc_extensions(format) : nullptr;
    REOBSBasicConfigInstance->setOutputFormat(formatName, formatMimeType, formatExtension);
    NSString *strVBitrate = self.vBitrateBtn.title;
    REOBSBasicConfigInstance->setOutputVideoBitrate(strVBitrate.intValue);
    NSString *strVGOPSize = self.vGOPBtn.title;
    REOBSBasicConfigInstance->setOutputVideoGOPSize(strVGOPSize.intValue);
    
    NSInteger vCodecSize = self->vCodecDesc.size();
    if(_selVideoCodecIndex>=0 && vCodecSize>0 && _selVideoCodecIndex<vCodecSize) {
        REOBSCodecDesc &desc = self->vCodecDesc[_selVideoCodecIndex];
        REOBSBasicConfigInstance->setOutputVideoCodec(desc.id, desc.name);
    }
    NSString *strVCodecParam = self.videoCodecParamTxt.cell.title;
    REOBSBasicConfigInstance->setOutputVideoCodecParam(strVCodecParam.UTF8String);
    
    //设置音频参数
    NSString *strBitrate = self.aBitrateBtn.cell.title;
    REOBSBasicConfigInstance->setOutputAudioBitrate(strBitrate.intValue);
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
    NSInteger aCodecSize = self->aCodecDesc.size();
    if(_selAudioCodecIndex>=0 && aCodecSize>0 && _selAudioCodecIndex<aCodecSize) {
        REOBSCodecDesc &desc = self->aCodecDesc[_selAudioCodecIndex];
        REOBSBasicConfigInstance->setOutputAudioCodec(desc.id, desc.name);
    }
    NSString *strACodecParam = self.audioCodecParamTxt.cell.title;
    REOBSBasicConfigInstance->setOutputAudioCodecParam(strACodecParam.UTF8String);
    
    REOBSBasicConfigInstance->saveCfg();
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

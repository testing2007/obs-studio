//
//  REOBSMainVC.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/19.
//

#import "REOBSMainVC.h"
#import "REOBS.h"

#include <string.h>
#include "Network/BXGNetworkTool.hpp"
#include "Network/BXGNetworkResult.hpp"
#include "Model/BXGPushStreamModel.hpp"

@interface REOBSMainVC ()<NSMenuDelegate> {
    const vector<REOBSFormatDesc> *formats;
    vector<REOBSCodecDesc> vCodecDesc;
    vector<REOBSCodecDesc> aCodecDesc;
    BXGPushStreamModel pushStreamModel;
}

@property (weak) IBOutlet NSTextField *liveTxt;
@property (weak) IBOutlet NSButton *hlsCheckBtn;
@property (weak) IBOutlet NSButton *flvCheckBtn;

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
@property (nonatomic, assign) bool bParamPush;
@property (weak) IBOutlet NSButton *btnParamPush;

@property (nonatomic, assign) bool bDefaultStream;
@property (weak) IBOutlet NSButton *btnDefaultPush;


@property (nonatomic, assign) int selVideoCodecIndex;
@property (nonatomic, assign) int selAudioCodecIndex;

@end

@implementation REOBSMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
//    [self.btnRecord setTitle:@"开始录制"];
    BXG_MGR_SHARE->setContentView(self.contentView);
    
    [self resetCtrl];
    [self loadData];
}

-(void)resetCtrl {
    [self.liveTxt.cell setTitle:@""];
    [self.liveTxt.cell setEnabled:false];//禁用
    
    [self.hlsCheckBtn setAction:@selector(onHLS:)];
    [self.flvCheckBtn setAction:@selector(onFLV:)];
    
    [self.hlsCheckBtn setState:NSControlStateValueOff];
    [self.flvCheckBtn setState:NSControlStateValueOff];
    
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
    
    [self checkFlv];
    const char* format = BXG_BASIC_CFG_SHARE->getOutputFormat();
    NSMenuItem *formatMenuItem = [[NSMenuItem alloc] initWithTitle:format==nullptr ? @("hls") : @(format) action:nil keyEquivalent:@("0")];
    if(format == nullptr) {
        BXG_BASIC_CFG_SHARE->setOutputFormat("hls", nullptr, "m3u8");
    }
    [self.formatBtn.cell.menu addItem:formatMenuItem];
    
    NSInteger nVBitrate = BXG_BASIC_CFG_SHARE->getOutputVideoBitrate();
    NSMenuItem *vBitrateMenuItem = [[NSMenuItem alloc] initWithTitle:nVBitrate==0 ? @("128") : @(nVBitrate).stringValue action:nil keyEquivalent:@("0")];
    [self.vBitrateBtn.cell.menu addItem:vBitrateMenuItem];
    
    NSInteger nGOPSize = BXG_BASIC_CFG_SHARE->getOutputVideoGOPSize();
    NSMenuItem *vGOPMenuItem = [[NSMenuItem alloc] initWithTitle:nGOPSize==0 ? @("90") : @(nGOPSize).stringValue action:nil keyEquivalent:@("0")];
    [self.vGOPBtn.cell.menu addItem:vGOPMenuItem];

    const char* vCodecName = BXG_BASIC_CFG_SHARE->getOutputVideoCodecName();
    NSMenuItem *vCodecMenuItem = [[NSMenuItem alloc] initWithTitle:vCodecName==nullptr ? @("libx264") : @(vCodecName) action:nil keyEquivalent:@("0")];
    if(vCodecName == nullptr) {
        BXG_BASIC_CFG_SHARE->setOutputVideoCodec(27, "libx264");
    }
    [self.videoCodecBtn.cell.menu addItem:vCodecMenuItem];
    
    const char* vCodecParams = BXG_BASIC_CFG_SHARE->getOutputVideoCodecParam();
    [self.videoCodecParamTxt.cell setTitle:vCodecParams==nullptr ? @"tune=zerolatency" : @(vCodecParams)];
    NSInteger nABitrate = BXG_BASIC_CFG_SHARE->getOutputAudioBitrate();
    NSMenuItem *aBitrateMenuItem = [[NSMenuItem alloc] initWithTitle:nABitrate==0 ? @("96") : @(nABitrate).stringValue action:nil keyEquivalent:@("0")];
    [self.aBitrateBtn.cell.menu addItem:aBitrateMenuItem];

    NSInteger audioMixes = BXG_BASIC_CFG_SHARE->getOutputAudioMixes();
    [self.aCheckBtn1 setState:(audioMixes & (1 << 0)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn2 setState:(audioMixes & (1 << 1)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn3 setState:(audioMixes & (1 << 2)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn4 setState:(audioMixes & (1 << 3)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn5 setState:(audioMixes & (1 << 4)) ? NSControlStateValueOn : NSControlStateValueOff ];
    [self.aCheckBtn6 setState:(audioMixes & (1 << 5)) ? NSControlStateValueOn : NSControlStateValueOff ];

    const char* aCodecName = BXG_BASIC_CFG_SHARE->getOutputAudioCodecName();
    NSMenuItem *aCodecMenuItem = [[NSMenuItem alloc] initWithTitle:aCodecName==nullptr ? @("aac") : @(aCodecName) action:nil keyEquivalent:@("0")];
    if(aCodecName == nullptr) {
        BXG_BASIC_CFG_SHARE->setOutputAudioCodec(86018, "aac");
    }
    [self.audioCodecBtn.cell.menu addItem:aCodecMenuItem];

    const char* aCodecParams = BXG_BASIC_CFG_SHARE->getOutputAudioCodecParam();
    [self.audioCodecParamTxt.cell setTitle:vCodecParams==nullptr ? @"" : @(aCodecParams)];
}

-(void)loadData {
    const char* url = BXG_BASIC_CFG_SHARE->getOutputURL();
    if(url == nullptr) {
        [self checkHLS];
    } else {
        std::string strURL = url;
        size_t pos = strURL.find_first_of('/');
        std::string tempStr = strURL.substr(pos);
        size_t pos2 = tempStr.find_first_of('/');
        std::string type = strURL.substr(pos, pos2);
        if(type.compare("flv") == 0) {
            [self checkFlv];
        } else if(type.compare("hls") == 0) {
            [self checkHLS];
        } else {
            url = nullptr;
        }
    }
    
    int lastSelIndex;
    self->formats = &(BXG_MGR_SHARE->getFormats(lastSelIndex));
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
    [self.flvCheckBtn setEnabled:false];
    
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
    BXG_MGR_SHARE->reloadCodecs(newFormat.desc, self->vCodecDesc, defaultVideoCodecIndex, self->aCodecDesc, defaultAudioCodecIndex);

    //填充音视频控件值 TODO:step value
    [self fillVideoCodecsCtrl:vCodecDesc];

    [self fillAudioCodecsCtrl:aCodecDesc];


    //禁用/启用视频相关控件
    NSInteger userSelVideoId = BXG_BASIC_CFG_SHARE->getOutputVideoCodecId();
    [self.vBitrateBtn setEnabled:defaultVideoCodecIndex == -1 && userSelVideoId==0 ? false : true];
    [self.vGOPBtn setEnabled:defaultVideoCodecIndex == -1  && userSelVideoId==0 ? false : true];
    [self.videoCodecBtn setEnabled:defaultVideoCodecIndex == -1  && userSelVideoId==0 ? false : true];
    [self.videoCodecParamTxt setEnabled:defaultVideoCodecIndex == -1  && userSelVideoId==0 ? false : true];

    //禁用/启用音频相关控件
    NSInteger userSelAudioId = BXG_BASIC_CFG_SHARE->getOutputAudioCodecId();
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
    int64_t selCodecId = BXG_BASIC_CFG_SHARE->getOutputVideoCodecId();
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
    int64_t selCodecId = BXG_BASIC_CFG_SHARE->getOutputAudioCodecId();
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
    [self.flvCheckBtn setState:NSControlStateValueOff];
}

- (void)checkFlv {
    [self.flvCheckBtn setState:NSControlStateValueOn];
    [self.hlsCheckBtn setState:NSControlStateValueOff];
}

- (BOOL)isActive {
    return _bDefaultStream || _bParamPush;
}

-(void)windowWillClose:(NSNotification *)notification {
    BXG_MGR_SHARE->terminal();
}

-(void)getParamPushInfo {
    std::string msg;
    if(self.hlsCheckBtn.state) {
        BXGNetworkTool::share()->getPushStreamData(self->pushStreamModel, PUSH_CATEGORY_PARAM, PUSH_STYLE_HLS, "authCode",  msg);
    } else {
        BXGNetworkTool::share()->getPushStreamData(self->pushStreamModel, PUSH_CATEGORY_PARAM, PUSH_STYLE_FLV, "authCode", msg);
    }
    const std::string &pushURL = self->pushStreamModel.livePushAddress;
    if(pushURL.length() > 0) {
        [self.liveTxt.cell setTitle:@(pushURL.c_str())];
        BXG_BASIC_CFG_SHARE->setOutputURL(pushURL.c_str());
    }
}

-(void)getDefaultPushInfo {
    std::string msg;
    if(self.hlsCheckBtn.state) {
        BXGNetworkTool::share()->getPushStreamData(self->pushStreamModel, PUSH_CATEGORY_SERVICE, PUSH_STYLE_HLS, "authCode", msg);
    } else {
        BXGNetworkTool::share()->getPushStreamData(self->pushStreamModel, PUSH_CATEGORY_SERVICE, PUSH_STYLE_FLV, "authCode", msg);
    }
    const std::string &pushURL = self->pushStreamModel.livePushAddress;
    const std::string &roomId = self->pushStreamModel.roomId;
    if(pushURL.length() > 0 && roomId.length()>0) {
        [self.liveTxt.cell setTitle:@((pushURL+ "/" + roomId).c_str())];
        BXG_SERVER_CFG_SHARE->saveCustomService(pushURL.c_str(), roomId.c_str(), false, nullptr, nullptr);
    }
}

- (void)setBParamPush:(bool)bParamPush {
    if(bParamPush) {
        [self.btnParamPush setTitle:@"结束参数推流"];
    } else {
        [self.btnParamPush setTitle:@"开始参数推流"];
    }
    _bParamPush = bParamPush;
}

- (void)setBDefaultStream:(bool)bDefaultStream {
    if(bDefaultStream) {
        [self.btnDefaultPush setTitle:@"结束默认推流"];
    } else {
        [self.btnDefaultPush setTitle:@"开始默认推流"];
    }
    _bDefaultStream = bDefaultStream;
}

#pragma mark 行为方法
- (IBAction)onParamPush:(id)sender {
    if(_bParamPush) {
        BXG_MGR_SHARE->stopRecord();
        self.bParamPush = !_bParamPush;
    } else {
        if(![self isActive]) {
            [self getParamPushInfo];
            BXG_MGR_SHARE->startRecord();
            self.bParamPush = !_bParamPush;
        } else {
            blog(LOG_INFO, "开启新的链路之前请先关闭现有的链路");
        }
    }
}

- (IBAction)onDefaultPush:(id)sender {
    if(_bDefaultStream) {
        BXG_MGR_SHARE->stopPushStream();
        self.bDefaultStream = !_bDefaultStream;
    } else {
        if(![self isActive]) {
            [self getDefaultPushInfo];
            BXG_MGR_SHARE->startPushStream();
            self.bDefaultStream = !_bDefaultStream;
        } else {
            blog(LOG_INFO, "开启新的链路之前请先关闭现有的链路");
        }
    }
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
    BXG_BASIC_CFG_SHARE->setOutputVideoCodec(selCodec.id, selCodec.name);
}

- (void)onChangeAudioCodec:(NSObject*)aCodec {
    NSString* strIndex = (NSString*)(aCodec);
    self.selAudioCodecIndex = strIndex.intValue;
    [self.audioCodecBtn selectItemAtIndex:self.selAudioCodecIndex];
    REOBSCodecDesc &selCodec = self->aCodecDesc[self.selAudioCodecIndex];
    BXG_BASIC_CFG_SHARE->setOutputAudioCodec(selCodec.id, selCodec.name);
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

- (void)onFLV:(NSButton*)rtmpObj {
    [self checkFlv];
}

- (IBAction)onConfirm:(id)sender {
    //设置视频参数
    NSString *strURL = (NSString*)(self.liveTxt.cell.title);
    BXG_BASIC_CFG_SHARE->setOutputURL(strURL.UTF8String);
    const struct ff_format_desc * format = BXG_MGR_SHARE->getCurFormatDesc();
    const char *formatName = format ? ff_format_desc_name(format) : nullptr;
    const char *formatMimeType = format ? ff_format_desc_mime_type(format) : nullptr;
    const char *formatExtension = format ? ff_format_desc_extensions(format) : nullptr;
    BXG_BASIC_CFG_SHARE->setOutputFormat(formatName, formatMimeType, formatExtension);
    NSString *strVBitrate = self.vBitrateBtn.title;
    BXG_BASIC_CFG_SHARE->setOutputVideoBitrate(strVBitrate.intValue);
    NSString *strVGOPSize = self.vGOPBtn.title;
    BXG_BASIC_CFG_SHARE->setOutputVideoGOPSize(strVGOPSize.intValue);
    
    NSInteger vCodecSize = self->vCodecDesc.size();
    if(_selVideoCodecIndex>=0 && vCodecSize>0 && _selVideoCodecIndex<vCodecSize) {
        REOBSCodecDesc &desc = self->vCodecDesc[_selVideoCodecIndex];
        BXG_BASIC_CFG_SHARE->setOutputVideoCodec(desc.id, desc.name);
    }
    NSString *strVCodecParam = self.videoCodecParamTxt.cell.title;
    BXG_BASIC_CFG_SHARE->setOutputVideoCodecParam(strVCodecParam.UTF8String);
    
    //设置音频参数
    NSString *strBitrate = self.aBitrateBtn.cell.title;
    BXG_BASIC_CFG_SHARE->setOutputAudioBitrate(strBitrate.intValue);
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
    BXG_BASIC_CFG_SHARE->setOutputAudioMixes(audioMixes);
    NSInteger aCodecSize = self->aCodecDesc.size();
    if(_selAudioCodecIndex>=0 && aCodecSize>0 && _selAudioCodecIndex<aCodecSize) {
        REOBSCodecDesc &desc = self->aCodecDesc[_selAudioCodecIndex];
        BXG_BASIC_CFG_SHARE->setOutputAudioCodec(desc.id, desc.name);
    }
    NSString *strACodecParam = self.audioCodecParamTxt.cell.title;
    BXG_BASIC_CFG_SHARE->setOutputAudioCodecParam(strACodecParam.UTF8String);
    
    BXG_BASIC_CFG_SHARE->saveCfg();
}

@end

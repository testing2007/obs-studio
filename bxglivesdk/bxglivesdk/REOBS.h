//
//  REOBS.h
//  obs-studio
//
//  Created by ZhiQiang wei on 2020/12/9.
//

#ifndef REOBS_h
#define REOBS_h

#import "obs.hpp"
#import "REOBSCommonMacro.h"
#import "REOBSCommon.h"
#import "REOBSManager.h"
#import "REOBSBasicConfig.h"
#import "REOBSServiceConfig.h"


#endif /* REOBS_h */

// 参数更改参考：
//[AdvOut]
//TrackIndex=1
//RecType=FFmpeg
//RecFormat=mp4
//RecTracks=1
//FLVTrack=1
//FFOutputToFile=false
//FFFormat=hls
//FFFormatMimeType=
//FFVEncoderId=27
//FFVEncoder=libx264
//FFAEncoderId=86018
//FFAEncoder=aac
//FFAudioMixes=1
//FFURL=rtmp://47.93.202.254/hls/test
//FFVCustom=tune=zerolatency
//FFExtension=m3u8
//FFVBitrate=512
//FFVGOPSize=90
//FFABitrate=96
//参考代码：
//inline void AdvancedOutput::SetupFFmpeg()

//
//  BXGPushStreamModel.hpp
//  bxglivesdk
//
//  Created by ZhiQiang wei on 2021/1/22.
//

#ifndef BXGPushStreamModel_hpp
#define BXGPushStreamModel_hpp

#include <stdio.h>
#include "BXGBaseModel.hpp"

class BXGPushStreamModel : BXGBaseModel {
public:
  NLOHMANN_DEFINE_TYPE_INTRUSIVE(BXGPushStreamModel, roomId, liveImage, liveSecret, rtmpAddress, startTime)

public:
    std::string roomId;
    std::string liveImage;
    std::string liveSecret;
    std::string rtmpAddress;
    std::string startTime;

private:
    NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(BXGPushStreamModel, roomId, liveImage, liveSecret, rtmpAddress, startTime)
};

#endif /* BXGPushStreamModel_hpp */

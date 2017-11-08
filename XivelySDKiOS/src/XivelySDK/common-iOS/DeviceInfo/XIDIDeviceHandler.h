//
//  XIDIDeviceInfoList.h
//  common-iOS
//
//  Copyright (c) 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/DeviceInfo/XIDeviceHandler.h>
#import "XIDeviceInfoCallProvider.h"
#import <Internals/SessionServices/XISessionServiceWithCallProvider.h>

@interface XIDIDeviceHandler : NSObject <XIDeviceHandler, XIDeviceInfoCallDelegate, XISessionServiceWithCallProvider>

@end

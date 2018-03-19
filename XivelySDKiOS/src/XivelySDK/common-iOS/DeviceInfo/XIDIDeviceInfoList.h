//
//  XIDIDeviceInfoList.h
//  common-iOS
//
//  Created by vfabian on 25/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/DeviceInfo/XIDeviceInfoList.h>
#import "XIDIDeviceInfoListCallProvider.h"
#import <Internals/SessionServices/XISessionServiceWithCallProvider.h>

@interface XIDIDeviceInfoList : NSObject <XIDeviceInfoList, XIDIDeviceInfoListCallDelegate, XISessionServiceWithCallProvider>

@end

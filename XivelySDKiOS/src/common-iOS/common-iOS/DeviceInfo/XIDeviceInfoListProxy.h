//
//  XIDeviceInfoListProxy.h
//  common-iOS
//
//  Created by vfabian on 25/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/DeviceInfo/XIDeviceInfoList.h>
#import <Internals/SessionServices/XISessionServiceProxy.h>

@interface XIDeviceInfoListProxy : NSObject <XIDeviceInfoList, XISessionServiceProxy>

@end

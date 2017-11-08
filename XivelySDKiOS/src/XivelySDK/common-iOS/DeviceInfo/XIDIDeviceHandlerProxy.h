//
//  XIDeviceHandlerProxy.h
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/DeviceInfo/XIDeviceHandler.h>
#import <Internals/SessionServices/XISessionServiceProxy.h>

@interface XIDIDeviceHandlerProxy : NSObject <XIDeviceHandler, XISessionServiceProxy>

@end

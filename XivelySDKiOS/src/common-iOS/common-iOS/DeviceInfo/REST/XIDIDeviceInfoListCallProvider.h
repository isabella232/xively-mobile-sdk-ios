//
//  XIDIDeviceInfoListCallProvider.h
//  common-iOS
//
//  Created by vfabian on 24/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIDIDeviceInfoListCall.h"

@protocol XIDIDeviceInfoListCallProvider <NSObject>

- (id<XIDIDeviceInfoListCall>)deviceInfoListCall;

@end

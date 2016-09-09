//
//  XIDeviceInfoCallProvider.h
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIDeviceInfoCall.h"

@protocol XIDeviceInfoCallProvider <NSObject>

- (id<XIDeviceInfoCall>)deviceInfoCall;

@end

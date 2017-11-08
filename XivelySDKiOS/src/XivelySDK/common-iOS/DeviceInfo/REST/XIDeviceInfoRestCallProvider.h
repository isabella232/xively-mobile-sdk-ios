//
//  XIDeviceInfoRestCallProvider.h
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIDeviceInfoCallProvider.h"
#import <Internals/SessionServices/XISessionServicesCallProvider.h>

@interface XIDeviceInfoRestCallProvider : NSObject <XIDeviceInfoCallProvider, XISessionServicesCallProvider>

@end

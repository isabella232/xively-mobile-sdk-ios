//
//  XIDeviceInfoRestCall.h
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIDeviceInfoCall.h"

@interface XIDeviceInfoRestCall : NSObject <XIDeviceInfoCall, XIRESTCallDelegate>

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig;


@end

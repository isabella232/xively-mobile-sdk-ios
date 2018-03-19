//
//  XICOCreateMqttCredentialsRestCallProvider.h
//  common-iOS
//
//  Created by vfabian on 03/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XICOCreateMqttCredentialsCallProvider.h"

@interface XICOCreateMqttCredentialsRestCallProvider : NSObject <XICOCreateMqttCredentialsCallProvider>

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig;


@end

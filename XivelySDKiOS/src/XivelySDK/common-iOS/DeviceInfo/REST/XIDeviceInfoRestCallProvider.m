//
//  XIDeviceInfoRestCallProvider.m
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import "XIDeviceInfoRestCallProvider.h"
#import "XIDeviceInfoRestCall.h"


@interface XIDeviceInfoRestCallProvider ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end


@implementation XIDeviceInfoRestCallProvider

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig {
    self = [super init];
    if (self) {
        self.log = logger;
        self.restCallProvider = provider;
        self.servicesConfig = servicesConfig;
    }
    return self;
}

- (id<XIDeviceInfoCall>)deviceInfoCall {
    return [[XIDeviceInfoRestCall alloc] initWithLogger:self.log
                                             restCallProvider:self.restCallProvider
                                               servicesConfig:self.servicesConfig];
}

@end

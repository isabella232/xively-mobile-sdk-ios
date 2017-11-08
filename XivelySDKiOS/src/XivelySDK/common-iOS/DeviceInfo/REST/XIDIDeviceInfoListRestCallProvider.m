//
//  XIDIDeviceInfoListRestCallProvider.m
//  common-iOS
//
//  Created by vfabian on 24/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIDIDeviceInfoListRestCallProvider.h"
#import "XIDIDeviceInfoListRestCall.h"


@interface XIDIDeviceInfoListRestCallProvider ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end


@implementation XIDIDeviceInfoListRestCallProvider

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

- (id<XIDIDeviceInfoListCall>)deviceInfoListCall {
    return [[XIDIDeviceInfoListRestCall alloc] initWithLogger:self.log
                                             restCallProvider:self.restCallProvider
                                               servicesConfig:self.servicesConfig];
}

@end

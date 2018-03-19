//
//  XICOCreateMqttCredentialsRestCallProvider.m
//  common-iOS
//
//  Created by vfabian on 03/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XICOCreateMqttCredentialsRestCallProvider.h"
#import "XICOCreateMqttCredentialsRestCall.h"

@interface XICOCreateMqttCredentialsRestCallProvider ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end

@implementation XICOCreateMqttCredentialsRestCallProvider

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


- (id<XICOCreateMqttCredentialsCall>)createMqttCredentialsCall {
    return [[XICOCreateMqttCredentialsRestCall alloc] initWithLogger:self.log
                                                restCallProvider:self.restCallProvider
                                                  servicesConfig:self.servicesConfig];

}


@end

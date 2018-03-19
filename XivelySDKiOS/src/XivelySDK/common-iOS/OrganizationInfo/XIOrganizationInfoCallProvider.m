//
//  XIOrganizationInfoCallProvider.m
//  common-iOS
//
//  Created by tkorodi on 19/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import "XIOrganizationInfoRestCallProvider.h"
#import "XIOrganizationInfoRestCall.h"


@interface XIOrganizationInfoRestCallProvider ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end


@implementation XIOrganizationInfoRestCallProvider

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

- (id<XIOrganizationInfoCall>)organizationInfoCall {
    return [[XIOrganizationInfoRestCall alloc] initWithLogger:self.log
                                       restCallProvider:self.restCallProvider
                                         servicesConfig:self.servicesConfig];
}

@end

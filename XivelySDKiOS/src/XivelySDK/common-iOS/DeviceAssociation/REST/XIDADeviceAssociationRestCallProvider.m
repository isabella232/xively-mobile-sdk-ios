//
//  XIDADeviceAssociationRestCallProvider.m
//  common-iOS
//
//  Created by vfabian on 17/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIDADeviceAssociationRestCallProvider.h"
#import "XIDADeviceAssociationRestCall.h"

@interface XIDADeviceAssociationRestCallProvider ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end


@implementation XIDADeviceAssociationRestCallProvider

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


- (id<XIDADeviceAssociationCall>)deviceAssociationCall {
    return [[XIDADeviceAssociationRestCall alloc] initWithLogger:self.log
                                                restCallProvider:self.restCallProvider
                                                  servicesConfig:self.servicesConfig];
}

@end

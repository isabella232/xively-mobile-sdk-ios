//
//  XITSTimeSeriesRestCallProvider.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XITSTimeSeriesRestCallProvider.h"
#import "XITSTimeSeriesRestCall.h"

@interface XITSTimeSeriesRestCallProvider ()

@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) id<XIRESTCall> call;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;

@end


@implementation XITSTimeSeriesRestCallProvider

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

- (id<XITSTimeSeriesCall>)timeSeriesCall {
    return [[XITSTimeSeriesRestCall alloc] initWithLogger:self.log
                                             restCallProvider:self.restCallProvider
                                               servicesConfig:self.servicesConfig];
}


@end

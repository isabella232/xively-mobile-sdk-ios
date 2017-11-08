//
//  XIRESTCallProviderInternal.m
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIRESTCallProviderInternal.h"
#import "XIRESTCallProvider.h"
#import "XIRobustRESTCall.h"
#import "XIRESTCall.h"
#import "XISimpleRESTCall.h"
#import "XITimer.h"
#import "XITimerProvider.h"
#import "XITimerProviderImpl.h"

/**
 * @brief XIRESTCallProviderInternal implementation.
 * @since Version 1.0
 */
@interface XIRESTCallProviderInternal ()

/**
 * @brief The config for the internal execution of the SDK.
 * @since Version 1.0
 */
@property(nonatomic, strong)XISdkConfig *config;

/**
 * @brief The provider of the default HTTP headers.
 * @since Version 1.0
 */
@property(nonatomic, strong)XIRESTDefaultHeadersProvider *defaultHeadersProvider;

/**
 * @brief Instances if \link XIRESTCallResponseRecognizer \endlink.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSArray *responseRecognizers;


@end


@implementation XIRESTCallProviderInternal

@synthesize config = _config;

+ (instancetype)restCallProviderWithConfig:(XISdkConfig *)config
                    defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)defaultHeadersProvider
                       responseRecognizers:(NSArray *)responseRecognizers {
    return [[[self class] alloc] initWithConfig:config defaultHeadersProvider:defaultHeadersProvider responseRecognizers:responseRecognizers];
}

- (instancetype)initWithConfig:(XISdkConfig *)config
        defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)defaultHeadersProvider
           responseRecognizers:(NSArray *)responseRecognizers{
    self = [super init];
    if (self) {
        assert(config);
        self.config = config;
        self.defaultHeadersProvider = defaultHeadersProvider;
        self.responseRecognizers = responseRecognizers;
    }
    return self;
}

- (id<XIRESTCall>)getEmptyRESTCall {
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self
                                                                            timerProvider:[[XITimerProviderImpl alloc] init]
                                                                                   config:self.config];
    return restCall;
}

#pragma mark -
#pragma mark XIRobustRESTCallSimpleCallProvider

- (id<XIRESTCall>)getEmptySimpleRESTCall {
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.config.urlSession
                                                           defaultHeadersProvider:self.defaultHeadersProvider
                                                              responseRecognizers:self.responseRecognizers];
    return restCall;
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
}

@end

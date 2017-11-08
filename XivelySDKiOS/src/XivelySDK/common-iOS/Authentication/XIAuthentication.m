//
//  XIOAuthAccessRequest.m
//  common-iOS
//
//  Created by vfabian on 07/05/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIAuthentication.h"

#import <Internals/ServicesConfig/XIServicesConfig.h>
#import <XivelySDK/XISdkConfig+Selector.h>
#import <Internals/RESTCall/XIRESTCallProviderInternal.h>
#import <Internals/RESTCall/XIRESTDefaultHeadersProvider.h>
#import <Internals/RESTCall/XIAccess+XIRESTDefaultHeadersProvider.h>
#import "XIAccess.h"
#import "XICOAuthenticationRestCall.h"
#import "XICOResolveUserRestCall.h"
#import "XIRESTCallResponseJwtRecognizer.h"
#import "XIAccess+XIRESTCallResponseRecognizerDelegate.h"
/** @file */

/**
 * @brief XIAuthentication private interface.
 * @since Version 1.0
 */
@interface XIAuthentication () {
@private
    /**
     * @brief The internal implementation of the request to proxy calls.
     * @since Version 1.0
     */
    id<XICOAuthenticating> _authentication;
}

@end


@implementation XIAuthentication
#pragma mark -
#pragma mark Properties
-(XIAuthenticationState) state {
    return [_authentication state];
}

-(void) setDelegate:(id<XIAuthenticationDelegate>)delegate {
    [_authentication setDelegate: delegate];
    
}

-(id<XIAuthenticationDelegate>) delegate {
    return [_authentication delegate];
}

-(NSError*) error {
    return [_authentication error];
}


#pragma mark -
#pragma mark Constructors
-(instancetype)init {
    return [self initWithSdkConfig: [[XISdkConfig alloc] init]];
}

-(instancetype) initWithSdkConfig: (XISdkConfig*) sdkConfig {
    XIAccess *access = [[XIAccess alloc] init];
    XIServicesConfig *servicesConfig = [[XIServicesConfig alloc] initWithSdkConfig: sdkConfig];
    XIRESTDefaultHeadersProvider *defaultHeadersProvider = [[XIRESTDefaultHeadersProvider alloc] initWithJwtSource:access];
    XIRESTCallResponseJwtRecognizer *jwtRecognizer = [[XIRESTCallResponseJwtRecognizer alloc] init];
    jwtRecognizer.delegate = access;
    
    
    id<XIRESTCallProvider> restCallProvider = [[XIRESTCallProviderInternal alloc] initWithConfig:sdkConfig
                                                                          defaultHeadersProvider:defaultHeadersProvider
                                               responseRecognizers:@[jwtRecognizer]];
    
    
    XICOAuthentication* internal = [[XICOAuthentication alloc] initWithLogger: [[XICOLogger sharedLogger] createLoggerWithFacility: @"Authentication"]
                                                             restCallProvider: restCallProvider
                                                               servicesConfig: servicesConfig
                                                                        proxy: self
                                                                       access: access
                                    authenticationCall:[[XICOAuthenticationRestCall alloc] initWithLogger:[[XICOLogger sharedLogger] createLoggerWithFacility: @"AuthenticationCall"]
                                                                                         restCallProvider:restCallProvider
                                                                                           servicesConfig:servicesConfig]
                                                               resolveUserCall:[[XICOResolveUserRestCall alloc] initWithLogger:[[XICOLogger sharedLogger] createLoggerWithFacility: @"GetUserCall"]
                                                                                                            restCallProvider:restCallProvider
                                                                                                              servicesConfig:servicesConfig]];
    return [self initWithAuthenticating: internal];
}

-(instancetype) initWithAuthenticating: (id<XICOAuthenticating>) authenticating {
    if ((self = [super init])) {
        _authentication = authenticating;
    }
    return self;
}

#pragma mark -
#pragma mark Public methods
- (void)requestLoginWithUsername:(NSString *)username
                         password:(NSString *)password
                        accountId:(NSString *)accountId {
    
    [_authentication requestSessionWithUsername: username
                                       password: password
                                      accountId: accountId];
}

- (void)cancel {
    
    [_authentication cancel];
}

@end

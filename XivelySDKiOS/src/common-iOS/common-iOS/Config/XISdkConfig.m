//
//  XISdkConfig.m
//  common-iOS
//
//  Created by vfabian on 26/05/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/XICommonImports.h>
#import <XivelySDK/XISdkConfig+Selector.h>
#import "XICOLogger.h"

/** @file */

/**
 * @brief XISdkConfig private interface.
 * @since Version 1.0
 */
@interface XISdkConfig () {
@private
    /**
     * @brief The timeout for any HTTP request in seconds.
     * @details It is the overall timeout for any HTTP call which applies disregarding the retry attempt
     * count and the waiting time between them. The default value is 15s.
     * @since Version 1.0
     */
    long _httpResponseTimeout;
    
    /**
     * @brief The URL session that is used for HTTP calls.
     * @since Version 1.0
     */
    NSURLSession *_urlSession;
    
    /**
     * @brief The timeout of the initial mqtt connection.
     * @details The default is 10s.
     * @since Version 1.0
     */
    long _mqttConnectTimeout;
    
    /**
     * @brief The number of attempts an MQTT connection is tried to build up if it fails.
     * @details The default is 5.
     * @since Version 1.0
     */
    int _mqttRetryAttempt;
    
    /**
     * @brief The the time spent between an MQTT connection error and the next connection retry attempt in seconds.
     * @details The default is 2s.
     * @since Version 1.0
     */
    long _mqttWaitOnReconnect;
    
    /**
     * @brief The default set URL session is used
     * @details The default is 2s.
     * @since Version 1.0
     */
    BOOL _defaultUrlSessionUsed;
    
    /**
     * @brief The environment to connect to.
     * @since Version 1.0
     */
    XIEnvironment _environment;
}

@end

@implementation XISdkConfig

@synthesize httpResponseTimeout = _httpResponseTimeout;
@synthesize urlSession = _urlSession;
@synthesize mqttConnectTimeout = _mqttConnectTimeout;
@synthesize mqttRetryAttempt = _mqttRetryAttempt;
@synthesize mqttWaitOnReconnect = _mqttWaitOnReconnect;

-(XIEnvironment) environment {
#if SELECTOR_BUILD
    return _environment;
#else
    return XIEnvironmentLive;
#endif
}

-(XILogLevel) logLevel {
    
    return [[XICOLogger sharedLogger] level];
}

-(void) setLogLevel:(XILogLevel)logLevel {
    
    [[XICOLogger sharedLogger] setLevel: logLevel];
}

- (void)setUrlSession:(NSURLSession *)urlSession {
    if (self.urlSession != urlSession) {
        if (_defaultUrlSessionUsed) {
            //In case of defaultly used url session it needs to be canceled before releasing.
            //If not canceled it leaks.
            [self.urlSession invalidateAndCancel];
            _defaultUrlSessionUsed = NO;
        }
        assert(urlSession);
        self.urlSession = urlSession;
    }
}

+ (instancetype)config {
    return [[[self class] alloc] initWithEnvironment:XIEnvironmentLive];
}

+ (instancetype)configWithEnvironment:(XIEnvironment)environment {
    return [[self alloc] initWithEnvironment:environment];
}

+ (instancetype)configWithHTTPResponseTimeout:(long)httpResponseTimeout
                                          urlSession:(NSURLSession *)urlSession
                                  mqttConnectTimeout:(long)mqttConnectTimeout
                                    mqttRetryAttempt:(int)mqttRetryAttempt
                                 mqttWaitOnReconnect:(long)mqttWaitOnReconnect {
    return [[[self class] alloc] initWithHTTPResponseTimeout:httpResponseTimeout
                                                  urlSession:urlSession
                                          mqttConnectTimeout:mqttConnectTimeout
                                            mqttRetryAttempt:mqttRetryAttempt
                                         mqttWaitOnReconnect:mqttWaitOnReconnect];
}

+ (instancetype)configWithHTTPResponseTimeout:(long)httpResponseTimeout
                                   urlSession:(NSURLSession *)urlSession
                           mqttConnectTimeout:(long)mqttConnectTimeout
                             mqttRetryAttempt:(int)mqttRetryAttempt
                          mqttWaitOnReconnect:(long)mqttWaitOnReconnect
                                  environment:(XIEnvironment)environment {
    return [[[self class] alloc] initWithHTTPResponseTimeout:httpResponseTimeout
                                                  urlSession:urlSession
                                          mqttConnectTimeout:mqttConnectTimeout
                                            mqttRetryAttempt:mqttRetryAttempt
                                         mqttWaitOnReconnect:mqttWaitOnReconnect
                                                 environment:environment];
}

- (instancetype)init {
    return [self initWithEnvironment:XIEnvironmentLive];
}

- (instancetype)initWithEnvironment:(XIEnvironment)environment {
    self = [super init];
    if (self) {
        _httpResponseTimeout = 15;
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _defaultUrlSessionUsed = YES;
        _mqttConnectTimeout = 15;
        _mqttRetryAttempt = 3;
        _mqttWaitOnReconnect = 2;
        _environment = environment;
        self.logLevel = XILogLevelWarning;
    }
    return self;
}

- (instancetype)initWithHTTPResponseTimeout:(long)httpResponseTimeout
                                 urlSession:(NSURLSession *)urlSession
                         mqttConnectTimeout:(long)mqttConnectTimeout
                           mqttRetryAttempt:(int)mqttRetryAttempt
                        mqttWaitOnReconnect:(long)mqttWaitOnReconnect {
    
    return [self initWithHTTPResponseTimeout:httpResponseTimeout
                                  urlSession:urlSession
                          mqttConnectTimeout:mqttConnectTimeout
                            mqttRetryAttempt:mqttRetryAttempt
                         mqttWaitOnReconnect:mqttWaitOnReconnect
                                 environment:XIEnvironmentLive];
}

- (instancetype)initWithHTTPResponseTimeout:(long)httpResponseTimeout
                                 urlSession:(NSURLSession *)urlSession
                         mqttConnectTimeout:(long)mqttConnectTimeout
                           mqttRetryAttempt:(int)mqttRetryAttempt
                        mqttWaitOnReconnect:(long)mqttWaitOnReconnect
                                environment:(XIEnvironment)environment {
    self = [self init];
    if (self) {
        if(httpResponseTimeout > 0) _httpResponseTimeout = httpResponseTimeout;
        if(urlSession) {
            [_urlSession invalidateAndCancel];
            _urlSession = urlSession;
            _defaultUrlSessionUsed = NO;
        }
        if(mqttConnectTimeout > 0) _mqttConnectTimeout = mqttConnectTimeout;
        if(mqttRetryAttempt > 0) _mqttRetryAttempt = mqttRetryAttempt;
        if(mqttWaitOnReconnect > 0) _mqttWaitOnReconnect = mqttWaitOnReconnect;
        _environment = environment;
    }
    return self;
}

+ (NSString *)version {
    NSString *selectorString = @"Normal";
#if SELECTOR_BUILD
    selectorString = @"Selector";
#endif
    
    NSString *debugString = @"Release";
#if DEBUG
    debugString = @"Debug";
#endif
    
#define xstr(s) str(s)
#define str(s) #s
    
    NSString *commitId = nil;
#ifdef _GIT_COMMIT_ID
    char * gitCommitId = xstr(_GIT_COMMIT_ID);
    commitId = [NSString stringWithUTF8String:gitCommitId];
#else
    commitId = @"";
#endif
    
#undef xstr
#undef str
    
    return [NSString stringWithFormat:@"Version 0.8 %@ %@ %@", commitId, selectorString, debugString];
}

- (void)dealloc {
    if (_defaultUrlSessionUsed) {
        [self.urlSession invalidateAndCancel];
    }
}

@end
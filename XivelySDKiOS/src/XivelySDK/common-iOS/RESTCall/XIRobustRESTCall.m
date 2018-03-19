//
//  XIRobustRESTCall.m
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIRobustRESTCall.h"
#import "XIRESTCall.h"
#import "XIRESTCallDelegate.h"
#import "XITimerProvider.h"
#import "XITimer.h"

const NSInteger XIRobustRESTCall_TimeoutErrorCode = 999;
const NSInteger XIRobustRESTCall_DefaultMaxRetryCount = 0;
const NSInteger XIRobustRESTCall_DefaultRetryWaitTime = 2;

@interface XIRobustRESTCall () 

/**
 * @brief The current state of the call.
 * @since Version 1.0
 */
@property(nonatomic, assign)XIRESTCallState state;

/**
 * @brief The result of the call if the call finished with success.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSData *result;

/**
 * @brief The error of the call if the call finished with error.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSError *error;

/**
 * @brief The provider for individual REST calls.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XIRobustRESTCallSimpleCallProvider> simpleCallProvider;

/**
 * @brief The timer provider for timeouts.
 * @since Version 1.0
 */
@property(nonatomic, strong)id<XITimerProvider> timerProvider;

/**
 * @brief The rect call currently running.
 * @since Version 1.0
 */
@property(nonatomic, strong)id<XIRESTCall> currentCall;

/**
 * @brief The URL to call.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSString *urlString;

/**
 * @brief The HTTP method to set for the call.
 * @since Version 1.0
 */
@property(nonatomic, assign)XIRESTCallMethod method;

/**
 * @brief The HTTP headers to add to the call.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSDictionary *headers;

/**
 * @brief The HTTP body to add to the call.
 * @since Version 1.0
 */
@property(nonatomic, strong)NSData *body;

/**
 * @brief The timer for a single call timeout.
 * @since Version 1.0
 */
@property(nonatomic, strong)id<XITimer> callTimeoutTimer;

/**
 * @brief The timer for a single call timeout.
 * @since Version 1.0
 */
@property(nonatomic, strong)id<XITimer> waitTimeoutTimer;

/**
 * @brief The current retry count.
 * @since Version 1.0
 */
@property(nonatomic, assign)NSInteger retryCount;

/**
 * @brief The config for the internal execution of the SDK.
 * @since Version 1.0
 */
@property(nonatomic, strong)XISdkConfig *config;


@end

@implementation XIRobustRESTCall

@synthesize retryCount = _retryCount;
@synthesize retryWaitTime = _retryWaitTime;
@synthesize simpleCallProvider = _simpleCallProvider;
@synthesize state = _state;
@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize result = _result;
@synthesize currentCall = _currentCall;
@synthesize urlString = _urlString;
@synthesize method = _method;
@synthesize headers = _headers;
@synthesize body = _body;
@synthesize maximumRetryCount = _maximumRetryCount;
@synthesize callTimeoutTimer = _callTimeoutTimer;
@synthesize waitTimeoutTimer = _waitTimeoutTimer;
@synthesize timerProvider = _timerProvider;
@synthesize config = _config;

+ (instancetype)restCallInternalWithSimpleCallProvider:(id<XIRobustRESTCallSimpleCallProvider>)simpleCallProvider
                                         timerProvider:(id<XITimerProvider>)timerProvider
                                                config:(XISdkConfig *)config {
    return [[[self class] alloc] initWithSimpleCallProvider:simpleCallProvider timerProvider:timerProvider config:config];
}

- (instancetype)initWithSimpleCallProvider:(id<XIRobustRESTCallSimpleCallProvider>)simpleCallProvider
                             timerProvider:(id<XITimerProvider>)timerProvider
                                    config:(XISdkConfig *)config {
    self = [super init];
    if (self) {
        assert(simpleCallProvider);
        self.simpleCallProvider = simpleCallProvider;
        self.timerProvider = timerProvider;
        self.config = config;
        self.maximumRetryCount = XIRobustRESTCall_DefaultMaxRetryCount;
        self.retryWaitTime = XIRobustRESTCall_DefaultRetryWaitTime;
        
    }
    return self;
}

- (void)startWithURL:(NSString *)urlString method:(XIRESTCallMethod)method headers:(NSDictionary *)headers body:(NSData *)body {
    assert(urlString);
    assert(XIRESTCallMethodUndefined != method);
    
    if (_state != XIRESTCallStateIdle) return;
    self.state = XIRESTCallStateRunning;
    
    self.urlString = urlString;
    self.method = method;
    self.headers = headers;
    self.body = body;
    
    self.currentCall = [self.simpleCallProvider getEmptySimpleRESTCall];
    self.currentCall.delegate = self;
    [self.currentCall startWithURL:urlString method:method headers:headers body:body];
    self.callTimeoutTimer = [self.timerProvider getTimer];
    self.callTimeoutTimer.delegate = self;
    [self.callTimeoutTimer startWithTimeout:self.config.httpResponseTimeout periodic:NO];
}

- (void)cancel {
    if (_state == XIRESTCallStateRunning) {
        self.state = XIRESTCallStateCanceled;
        if (self.currentCall) {
            [self.currentCall cancel];
        }
        [self.callTimeoutTimer cancel];
        [self.waitTimeoutTimer cancel];
    }
}

#pragma mark -
#pragma mark XITimerDelegate
- (void)XITimerDidTick:(id<XITimer>)timer {
    if (timer == self.callTimeoutTimer) {
        [self cancel];
        [self.delegate XIRESTCall:self didFinishWithError:[NSError errorWithDomain:@"XIRESTCall" code:XIRobustRESTCall_TimeoutErrorCode userInfo:nil]];
    } else if (timer == self.waitTimeoutTimer) {
        self.currentCall = [self.simpleCallProvider getEmptySimpleRESTCall];
        self.currentCall.delegate = self;
        [self.currentCall startWithURL:self.urlString method:self.method headers:self.headers body:self.body];
    }
}

#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode{
    if (self.state != XIRESTCallStateRunning) return;
    [self.callTimeoutTimer cancel];
    self.callTimeoutTimer = nil;
    self.result = data;
    self.error = nil;
    self.state = XIRESTCallStateFinishedWithSuccess;
    [self.delegate XIRESTCall:call didFinishWithData:data httpStatusCode:httpStatusCode];
}

- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    if (self.state != XIRESTCallStateRunning) return;
    
    if (self.retryCount > self.maximumRetryCount - 1) {
        [self.callTimeoutTimer cancel];
        self.callTimeoutTimer = nil;
        self.result = nil;
        self.error = error;
        self.state = XIRESTCallStateFinishedWithError;
        [self.delegate XIRESTCall:call didFinishWithError:error];
    } else {
        self.waitTimeoutTimer = [self.timerProvider getTimer];
        self.waitTimeoutTimer.delegate = self;
        [self.waitTimeoutTimer startWithTimeout:self.retryWaitTime periodic:NO];
        self.retryCount++;
    }
}

- (void)dealloc {
    [self cancel];
}


@end

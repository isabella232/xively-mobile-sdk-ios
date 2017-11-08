//
//  XIRobustRESTCall.h
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XivelySDK/XISdkConfig.h>
#import <Internals/Timer/XITimerProvider.h>
#import <Internals/Timer/XITimer.h>
#import <Internals/RESTCall/XIRESTCall.h>
#import <Internals/RESTCall/XIRESTCallDelegate.h>

/**
 * @brief The request timed out error code.
 * @since Version 1.0
 */
extern const NSInteger XIRobustRESTCall_TimeoutErrorCode;

/**
 * @brief An interface to provide an single, one shot REST call.
 * @since Version 1.0
 */
@protocol XIRobustRESTCallSimpleCallProvider

/**
 * @brief Get the single call.
 * @returns The rest call.
 * @since Version 1.0
 */
- (id<XIRESTCall>)getEmptySimpleRESTCall;

@end

/**
 * @brief A robust rec call that has the XIRESTCall interface. It tries to reconnect if there was an error.
 * @since Version 1.0
 */
@interface XIRobustRESTCall : NSObject <XIRESTCall, XITimerDelegate, XIRESTCallDelegate>

/**
 * @brief The request retry count.
 * @since Version 1.0
 */
@property(nonatomic, assign)NSInteger maximumRetryCount;

/**
 * @brief The time spent between failed requests and next tries.
 * @since Version 1.0
 */

@property(nonatomic, assign)NSInteger retryWaitTime;

/**
 * @brief The constructor.
 * @param simpleCallProvider The provider for individual REST calls.
 * @param timerProvider The timeout timer provider.
 * @param config The config for the internal execution of the SDK.
 * @returns An XIRobustRESTCall object.
 * @since Version 1.0
 */
- (instancetype)initWithSimpleCallProvider:(id<XIRobustRESTCallSimpleCallProvider>)simpleCallProvider
                             timerProvider:(id<XITimerProvider>)timerProvider
                                    config:(XISdkConfig *)config;

/**
 * @brief The static constructor.
 * @param simpleCallProvider The provider for individual REST calls.
 * @param timerProvider The timeout timer provider.
 * @param config The config for the internal execution of the SDK.
 * @returns An XIRobustRESTCall object.
 * @since Version 1.0
 */
+ (instancetype)restCallInternalWithSimpleCallProvider:(id<XIRobustRESTCallSimpleCallProvider>)simpleCallProvider
                                         timerProvider:(id<XITimerProvider>)timerProvider
                                                config:(XISdkConfig *)config;

@end


//
//  XIRESTCall.h
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XIRESTCallDelegate;

/**
 @brief The HTTP methods
 @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIRESTCallMethod) {
    XIRESTCallMethodUndefined, /**< The call is not defined. @since Version 1.0 */
    XIRESTCallMethodPOST, /**< POST. @since Version 1.0 */
    XIRESTCallMethodGET, /**< GET @since Version 1.0 */
    XIRESTCallMethodPUT, /**< PUT @since Version 1.0 */
    XIRESTCallMethodDELETE /**< DELETE @since Version 1.0 */
};


/**
 @brief The states of \link XIRESTCall \endlink.
 @since Version 1.0
 */

typedef NS_ENUM(NSUInteger, XIRESTCallState) {
    XIRESTCallStateIdle, /**< The call is not started. @since Version 1.0 */
    XIRESTCallStateRunning, /**< The call is started and running. @since Version 1.0 */
    XIRESTCallStateCanceled, /**< The call is canceled. @since Version 1.0 */
    XIRESTCallStateFinishedWithSuccess, /**< The call is finished with success. @since Version 1.0 */
    XIRESTCallStateFinishedWithError, /**< The call is finished with error. @since Version 1.0 */
};


/**
 * @brief Interface for a rest call.
 * @since Version 1.0
 */
@protocol XIRESTCall <NSObject>

/**
 * @brief The delegate to call back the reult on.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XIRESTCallDelegate> delegate;

/**
 * @brief The current state of the call.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIRESTCallState state;

/**
 * @brief The result of the call if the call finished with success.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSData *result;

/**
 * @brief The error of the call if the call finished with error.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *error;

/**
 * @brief Start the call.
 * @param url The URL to call.
 * @param method The HTTP method to set for the call.
 * @param headers The HTTP headers to add to the call.
 * @param body The HTTP body to add to the call.
 * @since Version 1.0
 */
- (void)startWithURL:(NSString *)url method:(XIRESTCallMethod)method headers:(NSDictionary *)headers body:(NSData *)body;

/**
 * @brief Cancel the running call.
 * @since Version 1.0
 */
- (void)cancel;

@end

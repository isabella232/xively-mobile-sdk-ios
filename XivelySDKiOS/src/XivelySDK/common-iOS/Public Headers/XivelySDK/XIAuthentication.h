//
//  XIOAuthAccessRequest.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/XISession.h>
#import <XivelySDK/XISdkConfig.h>

/** @file */

@class XIAuthentication;

/**
 * @brief The current state of the authentication.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIAuthenticationState) {
    XIAuthenticationStateIdle,              /**< The object is created but not started yet. @since Version 1.0 */
    XIAuthenticationStateRunning,           /**< The authentication is running. @since Version 1.0 */
    XIAuthenticationStateError,             /**< The authentication ended with error. @since Version 1.0 */
    XIAuthenticationStateEnded,             /**< The authentication ended with success. @since Version 1.0 */
    XIAuthenticationStateCanceled           /**< The authentication was canceled. @since Version 1.0 */
};

/**
 * @brief The protocol that is used to call \link XIAuthentication XIAuthentication\endlink results on.
 * @since Version 1.0
 */
@protocol XIAuthenticationDelegate <NSObject>
/**
 * @brief The authentication did end with an error.
 * @param authentication The authentication instance that initiates the callback.
 * @param error The reason of the error. The possible reasons are defined in \link XICommonError.h \endlink and \link XIAuthenticationError.h \endlink.
 * @since Version 1.0
 */
- (void)authentication:(XIAuthentication *)authentication didFailWithError:(NSError *)error;

/**
 * @brief The request is finished successfully, and returns a valid \link XISession XISession \endlink object.
 * @param authentication The authentication instance that initiates the callback.
 * @param session The session that is created by the authentication.
 * @since Version 1.0
 */
- (void)authentication:(XIAuthentication *)authentication didCreateSession:(id<XISession>)session;
@end

/**
 * @brief This class initiates authentication towards Xively system.
 * @details This class executes the username/password based authentications towards Xively. It returns a \link XISession XISession \endlink
 * if the authentication was successfull.
 * <p>
 * First you need to create an instance and set its delegate.
 * Than you need to call \link XIAuthentication::requestLoginWithUsername:password:accountId:\endlink. If the parameters are correct,
 * its result is called back on \link XIAuthenticationDelegate::authentication:didCreateSession: \endlink
 * or \link XIAuthenticationDelegate::authentication:didFailWithError: \endlink whether it was a success or failure. The successfull branch return
 * the valid \link XISession XISession\endlink object that can be used to proceed further. 
 * </p>
 * @since Version 1.0
 */
@interface XIAuthentication : NSObject

/**
 * @brief The current state of the authentication.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIAuthenticationState state;

/**
 * @brief The delegate to call back the result on.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XIAuthenticationDelegate> delegate;

/**
 * @brief The error if the authentication finished with error. The possible error codes are defined in \link XICommonError.h \endlink and \link XIAuthenticationError.h \endlink.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *error;

/**
 * @brief It creates an authentication object with default configrations.
 * @returns An XIAuthentication object.
 * @since Version 1.0
 */
-(instancetype)init;

/**
 * @brief It creates an authentication object with the given SDK configurations. The SDK uses these configurations throughout its operations.
 * @returns An XIAuthentication object.
 * @since Version 1.0
 */
-(instancetype)initWithSdkConfig:(XISdkConfig*)sdkConfig;

/**
 * @brief Start a username/password authentication flow.
 * @param username The Xively username.
 * @param password The Xively password.
 * @param accountId The Xively account ID.
 * @since Version 1.0
 */
- (void)requestLoginWithUsername:(NSString *)username
                         password:(NSString *)password
                        accountId:(NSString *)accountId;

/**
 * @brief Cancel the authentication.
 * @since Version 1.0
 */
- (void)cancel;

@end

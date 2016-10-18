//
//  XIEndUserHandler.h
//  common-iOS
//
//  Created by tkorodi on 16/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/EndUserInfo/XIEndUserInfo.h>

@protocol XIEndUserHandler;

/**
 * @brief The current state of the EndUser info listing.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIEndUserHandlerState) {
    XIEndUserHandlerStateIdle,         /**< The object is created but not started yet. @since Version 1.0 */
    XIEndUserHandlerStateRunning,      /**< The listing is running. @since Version 1.0 */
    XIEndUserHandlerStateEnded,        /**< The listing ended successfully. @since Version 1.0 */
    XIEndUserHandlerStateError,        /**< The listing ended with an error. @since Version 1.0 */
    XIEndUserHandlerStateCanceled,     /**< The listing was canceled. @since Version 1.0 */
};

/**
 * @brief The delegate for device info listing.
 * @since Version 1.0
 */
@protocol XIEndUserHandlerDelegate <NSObject>

/**
 * @brief The EndUser info query finished with success.
 * @param EndUserHandler The EndUserHandler instance that initiates the callback.
 * @param EndUserInfo The EndUser info object.
 * @since Version 1.0
 */
- (void)endUserHandler:(id<XIEndUserHandler>)endUserHandler didReceiveEndUserInfo:(XIEndUserInfo *)endUserInfo;

/**
 * @brief The association finished with an error.
 * @param EndUserHandler The XIEndUserHandler instance that initiates the callback.
 * @param error The reason of the error. The possible error codes are defined in \link XICommonError.h \endlink.
 * @since Version 1.0
 */
- (void)endUserHandler:(id<XIEndUserHandler>)endUserHandler didFailWithError:(NSError *)error;

@end


/**
 * @brief Interface for objects that holds IoT EndUser info that are accessible.
 * @since Version 1.0
 */
@protocol XIEndUserHandler <NSObject>

/**
 * @brief The state of the handler object.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIEndUserHandlerState state;

/**
 * @brief The delegate to call back the result on.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XIEndUserHandlerDelegate> delegate;

/**
 * @brief The error if the query finished with error.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *error;

/**
 * @brief Request EndUser info identified by EndUserId asynchronously.
 * @since Version 1.0
 */
- (void)requestEndUser:(NSString*)endUserId;

/**
 * @brief List all organiaztions
 * @since Version 1.0
 */
- (void)putEndUser:(XIEndUserInfo*)endUser;

/**
 * @brief Cancel the query.
 * @since Version 1.0
 */
- (void)cancel;

@end
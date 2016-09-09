//
//  XIMessagingStateListener.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/Messaging/XIMessaging.h>

/** @file */

@protocol XIMessaging;

/**
 * @brief An interface to call back on messaging state changes.
 * @since Version 1.0
 */
@protocol XIMessagingStateListener <NSObject>

/**
 * @brief The current state of the messaging changed.
 * @param messaging The messaging originating the call.
 * @param state The new state of the messaging.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didChangeStateTo:(XIMessagingState)state;

/**
 * @brief The messaging connection is being ended by an error.
 * @param messaging The messaging originating the call.
 * @param error The arror that causes the connection end. The possible error codes are defined in \link XICommonError.h \endlink and \link XIMessagingError.h \endlink.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging willEndWithError:(NSError *)error;

@end
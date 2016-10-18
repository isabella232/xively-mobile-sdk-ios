//
//  XIMessagingError.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

/** @file */

/**
 * @brief Messaging specific errors.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIMessagingError) {
    XIMessagingErrorSubscriptionFailed = 400,       /**< The end user could not subscribe to the channel. The channel may not exist, or the user does not have access to it@since Version 1.0 */
    XIMessagingErrorInvalidConnectParameters = 401, /**< There can only be one shared messaging connection for a session at the same time. Currently there is a running one, but it was initialized with different Clean Session or Last Will parameters. @since Version 1.0 */
};

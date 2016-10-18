//
//  XISessionServices+Messaging.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/XISessionServices.h>
#import <XivelySDK/Messaging/XIMessagingCreator.h>

/** @file */

/**
 * @brief Category for creating messaging creator objects.
 * @since Version 1.0
 */
@interface XISessionServices (Messaging)

/**
 * @brief Create a creator instance that creates messaging objects.
 * @returns An object that implements \link XIMessagingCreator \endlink protocol.
 * @since Version 1.0
 */
- (id<XIMessagingCreator>)messagingCreator;

@end

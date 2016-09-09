//
//  XIMessagingSubscriptionListener.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

/** @file */

@protocol XIMessaging;

/**
 * @brief An interface to call back on subscription and unsubscription successes and failures.
 * @since Version 1.0
 */
@protocol XIMessagingSubscriptionListener <NSObject>

/**
 * @brief The messaging successfully subscribed to a channel.
 * @param messaging The messaging originating the call.
 * @param channel The channel it subscribed to.
 * @param qos The QoS level the server accepted to deliver messages.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didSubscribeToChannel:(NSString *)channel qos:(XIMessagingQoS)qos;

/**
 * @brief The messaging failed to subscribe to a channel.
 * @param messaging The messaging originating the call.
 * @param channel The channel it tried to subscribe to.
 * @param error The reason of the error.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didFailToSubscribeToChannel:(NSString *)channel error:(NSError *)error;

/**
 * @brief The messaging successfully unsubscribed from a channel.
 * @param messaging The messaging originating the call.
 * @param channel The channel it unsubscribed from.
 
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didUnsubscribeFromChannel:(NSString *)channel;

/**
 * @brief The messaging successfully unsubscribed from a channel.
 * @param messaging The messaging originating the call.
 * @param channel The channel it tried to unsubscribe from.
 * @param error The reason of the error.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didFailToUnsubscribeFromChannel:(NSString *)channel error:(NSError *)error;

@end
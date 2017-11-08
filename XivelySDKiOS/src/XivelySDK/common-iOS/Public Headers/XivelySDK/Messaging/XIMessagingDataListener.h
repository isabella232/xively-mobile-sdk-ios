//
//  XIMessagingDataListener.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

/** @file */

@protocol XIMessaging;

/**
 * @brief An interface to call back on message arrivals.
 * @since Version 1.0
 */
@protocol XIMessagingDataListener <NSObject>

/**
 * @brief A message arrived on a given channel.
 * @param messaging The messaging originating the call.
 * @param message The message data that was received.
 * @param channel The channel, the message came from.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didReceiveData:(NSData *)message onChannel:(NSString *)channel;
@optional

/**
 * @brief A message was successfully sent by the SDK user. 
 * @details It only works for \link XIMessagingQoSAtLeastOnce \endlink and \link XIMessagingQoSExactlyOnce \endlink QoS levels.
 * @param messaging The messaging originating the call.
 * @param messageId The ID of the message that was successfully delivered.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didSendDataWithId:(NSInteger)messageId;

@end

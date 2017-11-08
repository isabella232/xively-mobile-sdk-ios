//
//  XIMessaging.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XIMessagingDataListener;
@protocol XIMessagingStateListener;
@protocol XIMessagingSubscriptionListener;


/**
 @brief All messages sent by XIMessagingQoSAtMostOnce QoS level has this message ID. They are not verified on the data listener inteface.
 @since Version 1.0
 */
extern UInt16 const XIQoS0MessageId;

/** @file */

/**
 @brief The QoS level of publish and subscribe commands.
 @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIMessagingQoS) {
    XIMessagingQoSAtMostOnce = 0,   /**< The messages are sent at most once. @since Version 1.0 */
    XIMessagingQoSAtLeastOnce = 1,  /**< The messages are sent at least once. @since Version 1.0 */
    //XIMessagingQoSExactlyOnce = 2 /**< The messages are sent exactly once. Xively does not support this level currently. @since Version 1.0 */
};

/**
 @brief The states of \link XIMessaging \endlink.
 @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIMessagingState) {
    XIMessagingStateConnected,      /**< The messaging is up and running. @since Version 1.0 */
    XIMessagingStateReconnecting,   /**< The messaging is trying to reconnect. All published messages will be delivered on successful reconnection. @since Version 1.0 */
    XIMessagingStateDisconnecting,  /**< The messaging is disconnecting. @since Version 1.0 */
    XIMessagingStateClosed,         /**< The messaging is closed. @since Version 1.0 */
    XIMessagingStateError           /**< The messaging ended with an error. @since Version 1.0 */
};

/**
 * @brief The interface of the messaging creator.
 * @since Version 1.0
 */
@protocol XIMessaging <NSObject>

/**
 * @brief The current state of the messaging.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIMessagingState state;

/**
 * @brief If the messaging was ended by an error, this holds the error value. The possible error codes are defined in \link XICommonError.h \endlink and \link XIMessagingError.h \endlink.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *finalError;

/**
 * @brief Add a data listener.
 * @param listener The listener to be added.
 * @since Version 1.0
 */
- (void)addDataListener:(id<XIMessagingDataListener>)listener;

/**
 * @brief Remove a data listener.
 * @param listener The listener to be added.
 * @since Version 1.0
 */
- (void)removeDataListener:(id<XIMessagingDataListener>)listener;

/**
 * @brief Add a state listener.
 * @param listener The listener to be added.
 * @since Version 1.0
 */
- (void)addStateListener:(id<XIMessagingStateListener>)listener;

/**
 * @brief Remove a state listener.
 * @param listener The listener to be added.
 * @since Version 1.0
 */
- (void)removeStateListener:(id<XIMessagingStateListener>)listener;

/**
 * @brief Add a subscription listener.
 * @param listener The listener to be added.
 * @since Version 1.0
 */
- (void)addSubscriptionListener:(id<XIMessagingSubscriptionListener>)listener;

/**
 * @brief Remove a subscription listener.
 * @param listener The listener to be added.
 * @since Version 1.0
 */
- (void)removeSubscriptionListener:(id<XIMessagingSubscriptionListener>)listener;

/**
 * @brief Publish to a channel. It does not retain the message.
 * @param channel The channel to send the message.
 * @param message The message to be sent.
 * @param qos The QoS of the message to send with.
 * @returns The ID of the message sent.
 * @since Version 1.0
 */
- (NSUInteger)publishToChannel:(NSString *)channel message:(NSData *)message qos:(XIMessagingQoS)qos;

/**
 * @brief Publish to a channel. The retaining flag can be set.
 * @param channel The channel to send the message.
 * @param message The message to be sent.
 * @param qos The QoS of the message to send with.
 * @param retain YES if the message needs to be retained by the broker.
 * @returns The ID of the message sent.
 * @since Version 1.0
 */
- (NSUInteger)publishToChannel:(NSString *)channel message:(NSData *)message qos:(XIMessagingQoS)qos retain:(BOOL)retain;

/**
 * @brief Subcribe to a channel with a given QoS.
 * @param channel The channel to subscribe to.
 * @param qos The QoS for the subscription.
 * @since Version 1.0
 */
- (void)subscribeToChannel:(NSString *)channel qos:(XIMessagingQoS)qos;

/**
 * @brief Unsubscribe from a channel.
 * @param channel The channel to unsubscribe from.
 * @since Version 1.0
 */
- (void)unsubscribeFromChannel:(NSString *)channel;

/**
 * @brief Close controlling devices.
 * @since Version 1.0
 */
- (void)close;

@end
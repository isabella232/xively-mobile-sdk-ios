//
//  XILastWill.h
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

/** @file */

/**
 * @brief Last will data for a messaging connection.
 * @since Version 1.0
 */
@interface XILastWill : NSObject

/**
 * @brief The channel to send the last will message to.
 * @since Version 1.0
 */
@property (nonatomic, copy, readonly) NSString *channel;

/**
 * @brief The message to be sent as a last will.
 * @since Version 1.0
 */
@property (nonatomic, copy, readonly) NSData *message;

/**
 * @brief The QoS of the last will message.
 * @since Version 1.0
 */
@property (nonatomic, readonly) XIMessagingQoS qos;

/**
 * @brief YES if the last will message needs to be retained.
 * @since Version 1.0
 */
@property (nonatomic, readonly) BOOL retained;

/**
 * @brief Constructor.
 * @param channel The channel to send the last will message to.
 * @param message The message to be sent as a last will.
 * @param qos The QoS of the last will message.
 * @param retain YES if the last will message needs to be retained.
 * @returns A XILastWill instance.
 * @since Version 1.0
 */
- (instancetype)initWithChannel:(NSString *)channel message:(NSData *)message qos:(XIMessagingQoS)qos retain:(BOOL)retain;

/**
 * @brief Checks last will equivalence.
 * @param lastWill An other last will instance to be compared with.
 * @returns YES if the two last wills are the same.
 * @since Version 1.0
 */
- (BOOL)isEqualToLastWill:(XILastWill *)lastWill;
@end
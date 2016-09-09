//
//  XIDeviceChannel.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file */

/**
 * @brief The persistance types of a channel.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIDeviceChannelPersistanceType) {
    XIDeviceChannelPersistanceTypeSimple,       /**< The messages on this channel are not persisted. @since Version 1.0 */
    XIDeviceChannelPersistanceTypeTimeSeries,   /**< All the messages on this channel are saved in time series. @since Version 1.0 */
};

/**
 * @brief A channel of a device.
 * @since Version 1.0
 */
@interface XIDeviceChannel : NSObject

/**
 * @brief All the device parameters in a dictionary form.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSDictionary *parameters;

/**
 * @brief A channel id.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSString *channelId;

/**
 * @brief The persistance type of the channel.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIDeviceChannelPersistanceType persistenceType;

@end

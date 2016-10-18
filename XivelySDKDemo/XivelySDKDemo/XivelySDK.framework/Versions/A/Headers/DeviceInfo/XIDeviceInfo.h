//
//  XIDeviceInfo.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

/** @file */

#import <Foundation/Foundation.h>

/**
 * @brief The provisioning state of the device.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIDeviceInfoProvisioningState) {
    XIDeviceInfoProvisioningStateDefined,   /**< The device is defined, but cannot be associated. @since Version 1.0 */
    XIDeviceInfoProvisioningStateActivated, /**< The device is activated to be associated. @since Version 1.0 */
    XIDeviceInfoProvisioningStateAssociated,/**< The device is associated and ready to be used. @since Version 1.0 */
    XIDeviceInfoProvisioningStateReserved   /**< The device is reserved. @since Version 1.0 */
};

/**
 * @brief The properties of an IoT device.
 * @since Version 1.0
 */
@interface XIDeviceInfo : NSObject

/**
 * @brief All the device parameters in a dictionary form.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSDictionary *parameters;

/**
 * @brief All device fields in a dictionary form.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSDictionary *customFields;

/**
 * @brief New/Changed Key-Value pairs for device PUT.
 * @since Version 1.0
 */
@property(nonatomic)NSDictionary *fieldsToUpdate;

/**
 * @brief The id of the IoT device.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSString *deviceId;

/**
 * @brief The id of the IoT device.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSString *organizationId;

/**
 * @brief The serial number.
 * @since Version 1.0
 */
@property(nonatomic)NSString *serialNumber;

/**
 * @brief The current provisioning state.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIDeviceInfoProvisioningState provisioningState;

/**
 * @brief The device version.
 * @since Version 1.0
 */
@property(nonatomic)NSString *deviceVersion;

/**
 * @brief The device location.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSString *deviceLocation;

/**
 * @brief The device name.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSString *deviceName;

/**
 * @brief The purchase date.
 * @since Version 1.0
 */
@property(nonatomic)NSDate *purchaseDate;

/**
 * @brief The list of channels of the device. The elements of the array are all the instances of \link XIDeviceChannel \endlink class.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSArray *deviceChannels;


/**
 * @brief The database version of the device info
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSString *version;

@end

//
//  XIDeviceChannel+XIDeviceInfoListing.h
//  Copyright (c) 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/DeviceInfo/XIDeviceInfo.h>

/** @file */

@protocol XIDeviceHandler;

/**
 * @brief The current state of the device info listing.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIDeviceHandlerState) {
    XIDeviceHandlerStateIdle,         /**< The object is created but not started yet. @since Version 1.0 */
    XIDeviceHandlerStateRunning,  /**< The listing is running. @since Version 1.0 */
    XIDeviceHandlerStateEnded,        /**< The listing ended successfully. @since Version 1.0 */
    XIDeviceHandlerStateError,        /**< The listing ended with an error. @since Version 1.0 */
    XIDeviceHandlerStateCanceled,     /**< The listing was canceled. @since Version 1.0 */
};

/**
 * @brief The delegate for device info listing.
 * @since Version 1.0
 */
@protocol XIDeviceHandlerDelegate <NSObject>

/**
 * @brief The device info query finished with success.
 * @param deviceHandler The deviceHandler instance that initiates the callback.
 * @param deviceInfo The device info object.
 * @since Version 1.0
 */
- (void)deviceHandler:(id<XIDeviceHandler>)deviceHandler didReceiveDeviceInfo:(XIDeviceInfo *)deviceInfo;

/**
 * @brief The association finished with an error.
 * @param XIDeviceHandler The XIDeviceHandler instance that initiates the callback.
 * @param error The reason of the error. The possible error codes are defined in \link XICommonError.h \endlink and \link XIDeviceInfoError.h \endlink.
 * @since Version 1.0
 */
- (void)deviceHandler:(id<XIDeviceHandler>)deviceHandler didFailWithError:(NSError *)error;

@end


/**
 * @brief Interface for objects that list IoT device info containers that are accessible for the end user.
 * @since Version 1.0
 */
@protocol XIDeviceHandler <NSObject>

/**
 * @brief The state of the listing object.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIDeviceHandlerState state;

/**
 * @brief The delegate to call back the listing result on.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XIDeviceHandlerDelegate> delegate;

/**
 * @brief The error if the listing finished with error.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *error;

/**
 * @brief Request the IoT device identified by deviceId asynchronously.
 * @since Version 1.0
 */
- (void)requestDevice:(NSString*)deviceId;

/**
 * @brief Updates the properties for a device.
 * @since Version 1.0
 */
- (void)putDevice:(XIDeviceInfo*)deviceInfo;

/**
 * @brief Cancel the listing.
 * @since Version 1.0
 */
- (void)cancel;

@end
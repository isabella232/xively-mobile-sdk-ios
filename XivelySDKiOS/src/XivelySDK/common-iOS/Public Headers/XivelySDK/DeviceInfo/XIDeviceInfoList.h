//
//  XIDeviceChannel+XIDeviceInfoListing.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file */

@protocol XIDeviceInfoList;

/**
 * @brief The current state of the device info listing.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIDeviceInfoListState) {
    XIDeviceInfoListStateIdle,         /**< The object is created but not started yet. @since Version 1.0 */
    XIDeviceInfoListStateRunning,  /**< The listing is running. @since Version 1.0 */
    XIDeviceInfoListStateEnded,        /**< The listing ended successfully. @since Version 1.0 */
    XIDeviceInfoListStateError,        /**< The listing ended with an error. @since Version 1.0 */
    XIDeviceInfoListStateCanceled,     /**< The listing was canceled. @since Version 1.0 */
};

/**
 * @brief The delegate for device info listing.
 * @since Version 1.0
 */
@protocol XIDeviceInfoListDelegate <NSObject>

/**
 * @brief The device info listing finished with success.
 * @param deviceInfoList The deviceInfoList instance that initiates the callback.
 * @param deviceInfos The device info container objects. They are all instances of \link XIDeviceInfo\endlink.
 * @since Version 1.0
 */
- (void)deviceInfoList:(id<XIDeviceInfoList>)deviceInfoList didReceiveList:(NSArray *)deviceInfos;

/**
 * @brief The association finished with an error.
 * @param deviceInfoList The deviceInfoList instance that initiates the callback.
 * @param error The reason of the error. The possible error codes are defined in \link XICommonError.h \endlink and \link XIDeviceInfoError.h \endlink.
 * @since Version 1.0
 */
- (void)deviceInfoList:(id<XIDeviceInfoList>)deviceInfoList didFailWithError:(NSError *)error;

@end


/**
 * @brief Interface for objects that list IoT device info containers that are accessible for the end user.
 * @since Version 1.0
 */
@protocol XIDeviceInfoList <NSObject>

/**
 * @brief The state of the listing object.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIDeviceInfoListState state;

/**
 * @brief The delegate to call back the listing result on.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XIDeviceInfoListDelegate> delegate;

/**
 * @brief The error if the listing finished with error.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *error;

/**
 * @brief Request the IoT device list asynchronously.
 * @since Version 1.0
 */
- (void)requestList;

/**
 * @brief Cancel the listing.
 * @since Version 1.0
 */
- (void)cancel;

@end

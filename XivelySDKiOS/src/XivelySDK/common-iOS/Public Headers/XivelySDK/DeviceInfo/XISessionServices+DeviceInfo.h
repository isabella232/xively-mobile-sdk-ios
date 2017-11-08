//
//  XISessionServices+DeviceInfo.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/XISessionServices.h>
#import <XivelySDK/DeviceInfo/XIDeviceInfoList.h>
#import <XivelySDK/DeviceInfo/XIDeviceHandler.h>

/** @file */

/**
 * @brief Category for creating device info list objects.
 * @since Version 1.0
 */
@interface XISessionServices (DeviceInfo)

/**
 * @brief Creates a device listing object.
 * @returns An object that implements \link XIDeviceInfoList \endlink protocol.
 * @since Version 1.0
 */
- (id<XIDeviceInfoList>)deviceInfoList;

/**
 * @brief Creates a device handler object.
 * @returns An object that implements \link XIDeviceHandler \endlink protocol.
 * @since Version 1.0
 */
- (id<XIDeviceHandler>)deviceHandler;


@end

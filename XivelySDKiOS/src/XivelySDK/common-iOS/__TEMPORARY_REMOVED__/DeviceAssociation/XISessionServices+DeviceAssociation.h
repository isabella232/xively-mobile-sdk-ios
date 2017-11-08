//
//  XISessionServices+DeviceAssociation.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/XISessionServices.h>
#import <XivelySDK/DeviceAssociation/XIDeviceAssociation.h>

/** @file */

/**
 * @brief Category for creating device associations.
 * @since Version 1.0
 */
@interface XISessionServices (DeviceAssociation)

/**
 * @brief Creates a device associations performer object.
 * @returns An object that implements \link XIDeviceAssociation \endlink protocol.
 * @since Version 1.0
 */
- (id<XIDeviceAssociation>)deviceAssociation;

@end

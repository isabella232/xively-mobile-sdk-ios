//
//  XIDeviceAssociationError.h
//  Copyright (c) 2015 Xively All rights reserved.
//

/** @file */

/**
 * @brief Device association specific errors.
 * @since Version 1.0
 */
typedef enum : NSUInteger {
    XIDeviceAssociationErrorInvalidCode = 300,          /**< The association code is invalid. @since Version 1.0 */
    XIDeviceAssociationErrorDeviceNotAssociatable = 301,/**< The association code is valid, but the device is already activated or not ready for activation. @since Version 1.0 */
} XIDeviceAssociationError;

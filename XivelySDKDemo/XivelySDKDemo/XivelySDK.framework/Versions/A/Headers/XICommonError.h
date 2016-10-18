//
//  XICommonError.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file */

/**
 @brief General errors in the SDK.
 @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIError) {
    XIErrorUnknown = 100,   /**< An unknown error has happened. @since Version 1.0 */
    XIErrorNetwork = 101,   /**< There is no network connection or it was lost. @since Version 1.0 */
    XIErrorTimeout = 102,   /**< An internal request timed out. @since Version 1.0 */
    XIErrorUnauthorized = 103, /**< The SDK or the end user is not authorized to request the service or initiate a call.  @since Version 1.0 */
    XIErrorInternal = 104,  /**< An internal error happened. @since Version 1.0 */
};


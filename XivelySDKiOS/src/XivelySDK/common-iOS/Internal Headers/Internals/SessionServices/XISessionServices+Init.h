//
//  XISessionServices+Init.h
//  common-iOS
//
//  Created by vfabian on 16/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <XivelySDK/XISessionServices.h>
#import <Internals/SessionServices/XISessionServicesInternal.h>

/** @file */

@class XISessionServicesInternal;

/**
 * @brief A protocol for session services object creation.
 * @since Version 1.0
 */
@interface XISessionServices (Init)

/**
 * @brief The constructor with internal.
 * @param internal The internal implementation of session services.
 * @returns An XISessionServices object.
 * @since Version 1.0
 */
- (instancetype)initWithSessionServicesInternal:(XISessionServicesInternal *)internal;

@end

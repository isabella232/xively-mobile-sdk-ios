//
//  XISessionProxy.h
//  common-iOS
//
//  Created by vfabian on 14/01/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

/** @file */

#import <Foundation/Foundation.h>

#import <XivelySDK/XISession.h>
#import <Internals/Session/XISessionInternal.h>

/**
 * @brief The implementation of an xively session that hides an internal implementation.
 * @since Version 1.0
 */
@interface XISessionProxy : NSObject <XISession>

/**
 * @brief The static constructor.
 * @param internalSession The internal session to proxy the calls.
 * @returns An XISessionProxy object.
 * @since Version 1.0
 */
+ (instancetype)sessionWithInternal:(XISessionInternal *)internalSession;

/**
 * @brief The constructor.
 * @param internalSession The internal session to proxy the calls.
 * @returns An XISessionProxy object.
 * @since Version 1.0
 */
- (instancetype)initWithInternal:(XISessionInternal *)internalSession;

@end

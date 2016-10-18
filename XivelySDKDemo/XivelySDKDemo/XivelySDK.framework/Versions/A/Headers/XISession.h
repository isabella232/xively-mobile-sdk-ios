//
//  XISession.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/** @file */

@class XISessionServices;

/**
 @brief The states of \link XISession \endlink.
 @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XISessionState) {
    XISessionStateActive,   /**< The session is active. @since Version 1.0 */
    XISessionStateInactive  /**< The session is inactive. @since Version 1.0 */
};

/**
 * @brief The interface of a Xively session.
 * @since Version 1.0
 */
@protocol XISession <NSObject>

/**
 * @brief The current state of the session.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XISessionState state;

/**
 * @brief The operation is suspended.
 * @since Version 1.0
 */
@property(nonatomic, readonly)BOOL suspended;

/**
 * @brief The services creator object.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XISessionServices *services;

/**
 * @brief Close the currently running session.
 * @since Version 1.0
 */
- (void)close;

/**
 * @brief Suspend the current session. It needs to be called when the application goes to background.
 * @since Version 1.0
 */
- (void)suspend;

/**
 * @brief Resumes the current session. It needs to be called when the application comes back to foreground.
 * @since Version 1.0
 */
- (void)resume;

/**
 * @brief Log out the user. It is not supported now.
 * @since Version 1.0
 */
- (void)logout;

@end

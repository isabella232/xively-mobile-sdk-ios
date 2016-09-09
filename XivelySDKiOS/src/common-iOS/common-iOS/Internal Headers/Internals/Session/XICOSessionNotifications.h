//
//  XICOSessionNotifications.h
//  common-iOS
//
//  Created by vfabian on 07/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief A class for message exchange between parties in the SDK.
 * @since Version 1.0
 */
@interface XICOSessionNotifications : NSObject

@property(nonatomic, readonly)NSNotificationCenter *sessionNotificationCenter;

@end

/**
 * @brief The session was suspended.
 * @since Version 1.0
 */
extern NSString * const XISessionDidSuspendNotification;

/**
 * @brief The session was resumed.
 * @since Version 1.0
 */
extern NSString * const XISessionDidResumeNotification;

/**
 * @brief The session was resumed.
 * @since Version 1.0
 */
extern NSString * const XISessionDidCloseNotification;

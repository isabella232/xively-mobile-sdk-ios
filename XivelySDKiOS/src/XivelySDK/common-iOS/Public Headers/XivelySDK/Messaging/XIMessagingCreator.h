//
//  XIMessagingCreator.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/XIServiceCreator.h>
#import <XivelySDK/Messaging/XIMessaging.h>
#import <XivelySDK/Messaging/XILastWill.h>

@protocol XIMessagingCreator;

/** @file */

/**
 * @brief The protocol is to call back the messaging creation result on.
 * @since Version 1.0
 */
@protocol XIMessagingCreatorDelegate <NSObject>

/**
 * @brief The messaging creation was successful. The running messaging is returned.
 * @param creator The messaging creator that created the messaging.
 * @param messaging The active messaging.
 * @since Version 1.0
 */
- (void)messagingCreator:(id<XIMessagingCreator>)creator didCreateMessaging:(id<XIMessaging>)messaging;

/**
 * @brief The messaging creation was not successful.
 * @param creator The messaging creator that created the messaging.
 * @param error The error description. The possible error codes are defined in \link XICommonError.h \endlink and \link XIMessagingError.h \endlink. 
 * @since Version 1.0
 */
- (void)messagingCreator:(id<XIMessagingCreator>)creator didFailToCreateMessagingWithError:(NSError *)error;

@end

/**
 * @brief The interface of the messaging creator.
 * @since Version 1.0
 */
@protocol XIMessagingCreator <XIServiceCreator>

/**
 * @brief Strict typed reference to \link XIServiceCreator::result\endlink.
 * @since Version 1.0
 */
@property(nonatomic, readonly)id<XIMessaging> resultMessaging;

/**
 * @brief Strict typed reference to \link XIServiceCreator::delegate\endlink.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XIMessagingCreatorDelegate> messagingCreatorDelegate;

/**
 * @brief Start to create a messaging.
 * @since Version 1.0
 */
- (void)createMessaging;

/**
 * @brief Start to create a messaging.
 * @since Version 1.0
 */
- (void)createMessagingWithCleanSession: (BOOL) cleanSession;

/**
 * @brief Start to create a messaging.
 * @since Version 1.0
 */
- (void)createMessagingWithCleanSession: (BOOL) cleanSession lastWill: (XILastWill*) lastWill;

@end
//
//  XISessionInternal.h
//  common-iOS
//
//  Created by vfabian on 29/04/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XivelySDK/XISession.h>
#import <XivelySDK/XIEnvironment.h>
#import <Internals/Session/XICOSessionNotifications.h>

@protocol XICOLogging;
@protocol XICOConnectionPooling;
@class XIAccess;
@class XIServicesConfig;

/**
 * @brief The implementation of an xively session.
 * @since Version 1.0
 */
@interface XISessionInternal : NSObject <XISession>

/**
 * @brief The object the delegate is called back in on behalf.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XISession> delegateCaller;

/**
 * @brief The pool for creating MQTT connections.
 * @since Version 1.0
 */
@property(nonatomic, readonly)id<XICOConnectionPooling> connectionPool;

/**
 * @brief The access object with the credentials.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIAccess *access;

/**
 * @brief The services config object with SDK properties.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIServicesConfig* servicesConfig;

/**
 * @brief The logger.
 * @since Version 1.0
 */
@property(readonly, readonly)id<XICOLogging> log;

/**
 * @brief The provider of rest calls.
 * @since Version 1.0
 */
@property(nonatomic, readonly)id<XIRESTCallProvider> restCallProvider;

/**
 * @brief The noifications center in the session.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XICOSessionNotifications *notifications;

/**
 * @brief The static constructor.
 * @param logger The logger.
 * @param provider The provider of rest calls.
 * @param servicesConfig The config for the internal execution of the SDK.
 * @param access The access data for the session.
 * @returns An XISessionInternal object.
 * @since Version 1.0
 */
+ (instancetype)sessionWithLogger:(id<XICOLogging>)logger
                 restCallProvider:(id<XIRESTCallProvider>)provider
                   servicesConfig:(XIServicesConfig *)servicesConfig
                           access:(XIAccess *)access;

/**
 * @brief The constructor.
 * @param logger The logger.
 * @param provider The provider of rest calls.
 * @param servicesConfig The config for the internal execution of the SDK.
 * @param access The access data for the session.
 * @returns An XISessionInternal object.
 * @since Version 1.0
 */
- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig
                        access:(XIAccess *)access;

/**
 * @brief The constructor.
 * @param logger The logger.
 * @param provider The provider of rest calls.
 * @param servicesConfig The config for the internal execution of the SDK.
 * @param access The access data for the session.
 * @param connectionPool MQTT connection pool.
 * @param notifications Notification center of the SDK.
 * @returns An XISessionInternal object.
 * @since Version 1.0
 */
- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig
                        access:(XIAccess *)access
                connectionPool:(id<XICOConnectionPooling>)connectionPool
                 notifications:(XICOSessionNotifications *)notifications;

@end

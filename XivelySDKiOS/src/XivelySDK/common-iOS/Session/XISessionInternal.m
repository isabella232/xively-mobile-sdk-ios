//
//  XISessionInternal.m
//  common-iOS
//
//  Created by vfabian on 29/04/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XISessionInternal.h"
#import "XISessionProxy.h"
#import "XISession.h"
#import "XICommonError.h"
#import "XISessionServicesInternal.h"
#import "XIAccess.h"
#import "XIServicesConfig.h"
#import "XICOConnectionPool.h"
#import "XICOCreateMqttCredentialsRestCallProvider.h"
#import <Internals/Session/XICOSessionNotifications.h>
#import <Internals/Timer/XITimerProviderImpl.h>
#import <Internals/SessionServices/XISessionServices+Init.h>

/**
 * @brief XISessionInternal private interface.
 * @since Version 1.0
 */
@interface XISessionInternal ()

/**
 * @brief The services creator.
 * @since Version 1.0
 */
@property(nonatomic, strong)XISessionServices *services;

/**
 * @brief The access object with the credentials.
 * @since Version 1.0
 */
@property(nonatomic, strong)XIAccess *access;

/**
 * @brief The current state of the session.
 * @since Version 1.0
 */
@property(nonatomic, assign)XISessionState state;

/**
 * @brief The config for the internal execution of the SDK.
 * @since Version 1.0
 */
@property(nonatomic, strong)XIServicesConfig *servicesConfig;

/**
 * @brief The operation is suspended.
 * @since Version 1.0
 */
@property(nonatomic, assign)BOOL suspended;

/**
 * @brief The pool for creating MQTT connections.
 * @since Version 1.0
 */
@property(nonatomic, strong)id<XICOConnectionPooling> connectionPool;

/**
 * @brief The logger.
 * @since Version 1.0
 */
@property(strong, nonatomic)id<XICOLogging> log;

/**
 * @brief The provider of rest calls.
 * @since Version 1.0
 */
@property(strong, nonatomic)id<XIRESTCallProvider> restCallProvider;

/**
 * @brief The noifications center in the session.
 * @since Version 1.0
 */
@property(strong, nonatomic)XICOSessionNotifications *notifications;

@end

@implementation XISessionInternal

@synthesize delegateCaller = _delegateCaller;
@synthesize access = _access;
@synthesize services = _services;
@synthesize state = _state;
@synthesize suspended = _suspended;
@synthesize servicesConfig = _servicesConfig;
@synthesize log = _log;
@synthesize restCallProvider = _restCallProvider;
@synthesize notifications = _notifications;

+ (instancetype)sessionWithLogger:(id<XICOLogging>)logger
                 restCallProvider:(id<XIRESTCallProvider>)provider
                   servicesConfig:(XIServicesConfig *)servicesConfig
                           access:(XIAccess *)access {
    return [[[self class] alloc] initWithLogger:logger
                               restCallProvider:provider
                                 servicesConfig:servicesConfig
                                         access:access];
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig
                        access:(XIAccess *)access {
    
    XICOSessionNotifications *notifications = [XICOSessionNotifications new];

    XICOConnectionPool *connectionPool = [[XICOConnectionPool alloc] initWithAccess:access
                                                                     servicesConfig:servicesConfig
                                                                  connectionFactory:[[XICOConnectionFactory alloc] initWithSdkConfig:servicesConfig.sdkConfig
                                                                                                                  mqttSessionFactory:[XICOMqttSessionFactory new]
                                                                                                                       timerProvider:[[XITimerProviderImpl alloc] init]
                                                                                                                       notifications:notifications]
                                                                             logger:logger
                                          createMqttCredentialsCallProvider:[[XICOCreateMqttCredentialsRestCallProvider alloc] initWithLogger:logger
                                                                                                                             restCallProvider:provider
                                                                                                                               servicesConfig:servicesConfig]
                                                                      notifications:notifications];
    return [self initWithLogger:logger
               restCallProvider:provider
                 servicesConfig:servicesConfig
                         access:access
                 connectionPool:connectionPool
            notifications:notifications];
    
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig
                        access:(XIAccess *)access
                connectionPool:(id<XICOConnectionPooling>)connectionPool
                 notifications:(XICOSessionNotifications *)notifications{
    self = [super init];
    if (self) {
        assert(access);
        assert(provider);
        assert(servicesConfig);
        self.access = access;
        self.services = [[XISessionServices alloc] initWithSessionServicesInternal:[XISessionServicesInternal servicesWithSession:self]];
        self.notifications = notifications;
        self.servicesConfig = servicesConfig;
        self.log = logger;
        self.restCallProvider = provider;
        self.connectionPool = connectionPool;
        
    }
    return self;
}

- (void)close {
    if (self.state == XISessionStateInactive) return;
    self.state = XISessionStateInactive;
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidCloseNotification object:nil];
}

- (void)suspend {
    if (self.state == XISessionStateInactive) return;
    if(_suspended) return;
    _suspended = YES;
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidSuspendNotification object:nil];
}

- (void)resume {
    if (self.state == XISessionStateInactive) return;
    if(!_suspended) return;
    _suspended = NO;
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidResumeNotification object:nil];
}

- (void)logout {
    assert(0 == "Logout is not supported yet");
}

#pragma mark -
#pragma mark Memory management
- (void) dealloc {
    [self close];
}

@end

//
//  XICOConnectionFactory.m
//  common-iOS
//
//  Created by gszajko on 27/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XICOConnectionFactory.h"

@interface XICOConnectionFactory ()
@property(nonatomic, strong) XISdkConfig* config;
@property(nonatomic, strong) XICOMqttSessionFactory* sessionFactory;
@property(nonatomic, strong) id<XITimerProvider> timerProvider;
@property(nonatomic, strong) XICOSessionNotifications *notifications;
@end

@implementation XICOConnectionFactory
-(instancetype) initWithSdkConfig: (XISdkConfig*) config
               mqttSessionFactory: (XICOMqttSessionFactory*) sessionFactory
                    timerProvider: (id<XITimerProvider>) timerProvider
                    notifications: (XICOSessionNotifications *)notifications{
    
    if ((self = [super init])) {
        _config = config;
        _sessionFactory = sessionFactory;
        _timerProvider = timerProvider;
        self.notifications = notifications;
    }
    
    return self;
}

-(id<XICOConnecting>) createConnectionWithLogger: (id<XICOLogging>) logger
                                  connectionPool: (id<XICOConnectionPooling>) connectionPool {

    return [[XICOConnection alloc] initWithSdkConfig: _config
                                              logger: logger
                                  mqttSessionFactory: _sessionFactory
                                       timerProvider: _timerProvider
                                      connectionPool: connectionPool
                                       notifications:self.notifications];
}
@end

//
//  XICOConnection.h
//  common-iOS
//
//  Created by gszajko on 09/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Internals/Session/XICOSessionNotifications.h>

@class MQTTSession;
@protocol XITimerProvider;
@protocol XICOConnectionPooling;

@interface XICOConnection : NSObject<XICOConnecting>
-(instancetype) initWithSdkConfig: (XISdkConfig*) config
                           logger: (id<XICOLogging>) logger
               mqttSessionFactory: (XICOMqttSessionFactory*) sessionFactory
                    timerProvider: (id<XITimerProvider>) timerProvider
                   connectionPool: (id<XICOConnectionPooling>) connectionPool
                    notifications: (XICOSessionNotifications *)notifications;
@end

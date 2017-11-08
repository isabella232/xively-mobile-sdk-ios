//
//  XICOConnectionFactory.h
//  common-iOS
//
//  Created by gszajko on 27/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Internals/Session/XICOSessionNotifications.h>

@interface XICOConnectionFactory : NSObject
-(id<XICOConnecting>) initWithSdkConfig: (XISdkConfig*) config
                     mqttSessionFactory: (XICOMqttSessionFactory*) sessionFactory
                          timerProvider: (id<XITimerProvider>) timerProvider
                          notifications: (XICOSessionNotifications *)notifications;

-(id<XICOConnecting>) createConnectionWithLogger: (id<XICOLogging>) logger
                                  connectionPool: (id<XICOConnectionPooling>) connectionPool;
@end

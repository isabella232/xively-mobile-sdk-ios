//
//  XICOConnectionPool.h
//  common-iOS
//
//  Created by gszajko on 22/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XICOCreateMqttCredentialsCallProvider.h"
#import <Internals/Session/XICOSessionNotifications.h>

#pragma mark -
#pragma mark XICOConnection connect/disconnect
@interface XICOConnection (ConnectDisconnect)
-(void) connectWithUrl: (NSURL*) brokerUrl
              username: (NSString*) username
              password: (NSString*) password
          cleanSession: (BOOL) cleanSession
              lastWill: (XILastWill*) lastWill;
-(void) disconnect;
@end


#pragma mark -
#pragma mark XICOConnectionPool
@interface XICOConnectionPool : NSObject<XICOConnectionPooling>
@property(nonatomic, strong)NSString* jwt;
-(instancetype) initWithAccess: (XIAccess*) access
                servicesConfig: (XIServicesConfig*) servicesConfig
             connectionFactory: (XICOConnectionFactory*) connectionFactory
                        logger: (id<XICOLogging>) logger
createMqttCredentialsCallProvider:(id<XICOCreateMqttCredentialsCallProvider>)createMqttCredentialsCallProvider
                 notifications:(XICOSessionNotifications *)notifications;

@end

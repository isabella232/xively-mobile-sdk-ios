//
//  XICOMqttSessionFactory.h
//  common-iOS
//
//  Created by gszajko on 10/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIMessaging.h"
#import "XILastWill.h"

@class MQTTSession;

@interface XICOMqttSessionFactory : NSObject
-(MQTTSession*)createMqttSessionWithClientId: (NSString*) clientId
                                    username: (NSString*) username
                                    password: (NSString*) password
                                   keepalive: (NSUInteger) keepalive
                                cleanSession: (BOOL) cleanSession
                                    lastWill: (XILastWill*) lastWill;
@end

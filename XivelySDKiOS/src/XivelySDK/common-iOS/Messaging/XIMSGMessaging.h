//
//  XIMSGMessaging.h
//  common-iOS
//
//  Created by vfabian on 23/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XivelySDK/Messaging/XIMessaging.h>
#import <Internals/Session/XICOSessionNotifications.h>

@interface XIMSGMessaging : NSObject <XIMessaging>

@property(nonatomic, weak)id<XIMessaging> proxy;

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                         proxy:(id<XIMessaging>)proxy
                    connection:(id<XICOConnecting>)connection
                 notifications:(XICOSessionNotifications *)notifications;

@end

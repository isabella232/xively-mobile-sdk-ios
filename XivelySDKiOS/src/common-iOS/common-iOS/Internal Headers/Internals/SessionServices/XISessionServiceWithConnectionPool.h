//
//  XISessionServiceWithConnectionPool.h
//  common-iOS
//
//  Created by vfabian on 05/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XISessionServiceWithConnectionPool <NSObject>

@property(nonatomic, weak)id proxy;

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                         proxy:(id)proxy
                           jwt:(NSString*)jwt
                connectionPool:(id<XICOConnectionPooling>)pool
                 notifications:(XICOSessionNotifications *)notifications;
@end

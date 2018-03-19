//
//  XIMSGMessagingCreator.h
//  common-iOS
//
//  Created by vfabian on 23/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XivelySDK/Messaging/XIMessagingCreator.h>
#import "XICOConnectionPooling.h"
#import "XICOConnectionPoolDelegate.h"
#import <Internals/Session/XICOSessionNotifications.h>
#import <Internals/SessionServices/XISessionServiceWithConnectionPool.h>


@interface XIMSGMessagingCreator : NSObject <XIMessagingCreator, XISessionServiceWithConnectionPool>

@end

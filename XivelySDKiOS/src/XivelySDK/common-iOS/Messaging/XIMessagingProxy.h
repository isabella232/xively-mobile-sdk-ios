//
//  XIMessagingProxy.h
//  common-iOS
//
//  Created by vfabian on 23/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XivelySDK/Messaging/XIMessaging.h>

@interface XIMessagingProxy : NSObject <XIMessaging>

- (instancetype)initWithInternal:(id<XIMessaging>)internal;

@end

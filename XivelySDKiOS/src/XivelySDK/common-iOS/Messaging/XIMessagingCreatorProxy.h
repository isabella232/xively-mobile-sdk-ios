//
//  XIMessagingCreatorProxy.h
//  common-iOS
//
//  Created by vfabian on 23/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XivelySDK/Messaging/XIMessagingCreator.h>

@interface XIMessagingCreatorProxy : NSObject <XIMessagingCreator>

- (instancetype)initWithInternal:(id<XIMessagingCreator>)internal;

@end

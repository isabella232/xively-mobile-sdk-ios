//
//  XICOSessionNotifications.m
//  common-iOS
//
//  Created by vfabian on 07/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XICOSessionNotifications.h"


NSString * const XISessionDidSuspendNotification = @"XISessionDidSuspendNotification";
NSString * const XISessionDidResumeNotification = @"XISessionDidResumeNotification";
NSString * const XISessionDidCloseNotification = @"XISessionDidCloseNotification";


@interface XICOSessionNotifications ()

@property(nonatomic, strong)NSNotificationCenter *sessionNotificationCenter;

@end

@implementation XICOSessionNotifications

@synthesize sessionNotificationCenter = _sessionNotificationCenter;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionNotificationCenter = [[NSNotificationCenter alloc] init];
    }
    return self;
}

@end

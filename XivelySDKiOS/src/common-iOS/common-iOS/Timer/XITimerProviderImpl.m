//
//  XITimerProviderImpl.m
//  common-iOS
//
//  Created by vfabian on 07/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Internals/Timer/XITimerProviderImpl.h>
#import <Internals/Timer/XITimerImpl.h>

@implementation XITimerProviderImpl

- (id<XITimer>)getTimer {
    return [[XITimerImpl alloc] init];
}

@end

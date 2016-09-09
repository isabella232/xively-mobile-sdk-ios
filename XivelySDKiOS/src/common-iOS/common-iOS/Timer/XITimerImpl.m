//
//  XITimerImpl.m
//  common-iOS
//
//  Created by vfabian on 13/02/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XITimerImpl.h"
#import "XITimer.h"

@interface XITimerImpl ()

@property(nonatomic, strong)NSTimer *timer;

@property(nonatomic, assign)BOOL periodic;

@end

@implementation XITimerImpl

@synthesize delegate = _delegate;
@synthesize periodic = _periodic;

- (void)startWithTimeout:(NSTimeInterval)timeout periodic:(BOOL)periodic {
    [self.timer invalidate];
    self.periodic = periodic;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(tick) userInfo:nil repeats:periodic];
}

- (void)cancel {
    [self.timer invalidate];
    self.timer = nil;
}

- (BOOL)isRunning {
    return (self.timer != nil);
}

- (void)tick {
    if (!self.periodic) {
        [self cancel];
    }
    [self.delegate XITimerDidTick:self];
}


@end

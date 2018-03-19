//
//  XITimer.h
//  common-iOS
//
//  Created by vfabian on 13/02/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XITimer;

@protocol XITimerDelegate <NSObject>

- (void)XITimerDidTick:(id<XITimer>)timer;

@end


@protocol XITimer <NSObject>

@property(nonatomic, weak)id<XITimerDelegate> delegate;

- (void)startWithTimeout:(NSTimeInterval)timeout periodic:(BOOL)periodic;

- (void)cancel;

- (BOOL)isRunning;

@end

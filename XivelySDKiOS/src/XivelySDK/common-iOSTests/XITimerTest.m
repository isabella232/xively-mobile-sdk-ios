//
//  XITimerTest.m
//  common-iOS
//
//  Created by vfabian on 13/02/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "XITimer.h"
#import "XITimerImpl.h"
#import "XITimerProviderImpl.h"

@interface XITimerTest : XCTestCase <XITimerDelegate>

@property(nonatomic, assign)BOOL timerTicked;

@end

@implementation XITimerTest

@synthesize timerTicked = _timerTicked;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXITimerCreation {
    XITimerImpl *timer = [[XITimerImpl alloc] init];
    XCTAssert(timer, @"Timer creation failed");
    timer.delegate = self;
    XCTAssertEqual(self, timer.delegate, @"Delegate setting failed");
}

- (void)testXITimerStartAndCancel {
    XITimerImpl *timer = [[XITimerImpl alloc] init];
    XCTAssert(timer, @"Timer creation failed");
    [timer startWithTimeout:60 periodic:NO];
    XCTAssertTrue(timer.isRunning, @"Timer is not running");
    [timer cancel];
    XCTAssertFalse(timer.isRunning, @"Timer is not running");
}

- (void)testXINotPeriodicTimerTick {
    XITimerImpl *timer = [[XITimerImpl alloc] init];
    timer.delegate = self;
    [timer startWithTimeout:60 periodic:NO];
    [timer tick];
    XCTAssertTrue(self.timerTicked, @"Timer tick not called back");
    XCTAssertFalse(timer.isRunning, @"Timer running while fired");
    [timer cancel];
}

- (void)testXIPeriodicTimerTick {
    XITimerImpl *timer = [[XITimerImpl alloc] init];
    timer.delegate = self;
    [timer startWithTimeout:60 periodic:YES];
    [timer tick];
    XCTAssertTrue(self.timerTicked, @"Timer tick not called back");
    XCTAssertTrue(timer.isRunning, @"Timer not running after fired");
    [timer cancel];
}

- (void)testXITimerProviderImplCreation {
    XITimerProviderImpl *timerProvider = [[XITimerProviderImpl alloc] init];
    XCTAssert(timerProvider, @"Creation failed");
}

- (void)testXITimerProviderImplTimerCreation {
    XITimerProviderImpl *timerProvider = [[XITimerProviderImpl alloc] init];
    XCTAssert([timerProvider getTimer], @"Timer Creation failed");
}


#pragma mark -
#pragma mark XITimerDelegate
- (void)XITimerDidTick:(id<XITimer>)timer {
    self.timerTicked = YES;
}

@end

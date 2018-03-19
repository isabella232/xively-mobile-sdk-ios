//
//  XICOFiniteStateMachineTests.m
//  common-iOS
//
//  Created by gszajko on 30/06/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import <OCMock/OCMockObject.h>

typedef NS_ENUM(NSInteger, TestState) {
    TestState0,
    TestState1,
    TestState2,
};

typedef NS_ENUM(NSInteger, TestEvent) {
    TestEvent0,
    TestEvent1,
    TestEvent2,
};

@interface XICOFiniteStateMachineTests : XCTestCase
@property (strong, nonatomic) XICOFiniteStateMachine* fsm;
@property (strong, nonatomic) XCTestExpectation* expectation1;
@property (strong, nonatomic) XCTestExpectation* expectation2;
@property (strong, nonatomic) XCTestExpectation* expectation3;
@end

@implementation XICOFiniteStateMachineTests

- (void)setUp {
    [super setUp];

    _fsm = [[XICOFiniteStateMachine alloc] initWithInitialState: TestState0];
}

- (void)tearDown {

    [super tearDown];
}

- (void)testInvocations {
    
    _expectation1 = [self expectationWithDescription: @"onState0Event0 called"];
    _expectation2 = [self expectationWithDescription: @"onState1Event1 called"];
    _expectation3 = [self expectationWithDescription: @"onState2Event2 called"];
    
    [_fsm addTransitionWithState: TestState0
                           event: TestEvent0
                          object: self
                        selector: @selector(onState0Event0:)];
    
    [_fsm addTransitionWithState: TestState1
                           event: TestEvent1
                          object: self
                        selector: @selector(onState1Event1:)];
    
    [_fsm addTransitionWithState: TestState2
                           event: TestEvent2
                          object: self
                        selector: @selector(onState2Event2:)];
    
    [_fsm doEvent: TestEvent0];
    [_fsm doEvent: TestEvent1];
    [_fsm doEvent: TestEvent2 withObject: @{@"hello": @"world"}];
    
    [self waitForExpectationsWithTimeout:1.0 handler: nil];
}

-(NSInteger) onState0Event0: (id) object {
    [_expectation1 fulfill];
    return TestState1;
}

-(NSInteger) onState1Event1: (id) object {
    [_expectation2 fulfill];
    return TestState2;
}

-(NSInteger) onState2Event2: (NSDictionary*) object {
    if ([object objectForKey: @"hello"]) {
        [_expectation3 fulfill];
    }
    return TestState0;
}

@end


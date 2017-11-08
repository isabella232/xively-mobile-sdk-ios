//
//  XIDeviceControlE2ETests.m
//  common-iOS
//
//  Created by gszajko on 09/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "E2ETestCase.h"
#import "XISessionServices+DeviceControl.h"
#import "XIDeviceControlSubscriptionListener.h"

@interface XIDeviceControlE2ETests : E2ETestCase <XIDeviceControlCreatorDelegate>
@property (strong, nonatomic) id<XIDeviceControlCreator> deviceControlCreator;
@property (strong, nonatomic) XCTestExpectation* deviceControlCreated;
@property (strong, nonatomic) id<XIDeviceControl> deviceControl;
@end

@implementation XIDeviceControlE2ETests
-(void) setUp {
    [super setUp];
    self.session = [self createEndUserSession];
    self.deviceControlCreated = [self expectationWithDescription: @"deviceControlCreated"];
    self.deviceControlCreator = [[self.session services] deviceControlCreator];
    [self.deviceControlCreator setDelegate: self];
    [self.deviceControlCreator createDeviceControl];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
}

- (void)deviceControlCreator:(id<XIDeviceControlCreator>)creator didCreateDeviceControl:(id<XIDeviceControl>)deviceControl {
    
    self.deviceControl = deviceControl;
    [self.deviceControlCreated fulfill];
}

- (void)deviceControlCreator:(id<XIDeviceControlCreator>)creator didFailToCreateDeviceControlWithError:(NSError *)error {
    [self.deviceControlCreated fulfill];
}

-(void) testCreateDeviceControlSubscriptionListener {
    
    XCTAssertNotNil(self.deviceControl);
    id subscriptionListener = OCMStrictProtocolMock(@protocol(XIDeviceControlSubscriptionListener));
    [self.deviceControl addSubscriptionListener: subscriptionListener];
    
    XCTestExpectation* failed = [self expectationWithDescription: @"didFailToSubscribeToChannel"];
    OCMExpect([subscriptionListener deviceControl: OCMOCK_ANY didFailToSubscribeToChannel: OCMOCK_ANY error: OCMOCK_ANY]).andDo(^(NSInvocation* i) {
        [failed fulfill];
    });
    
    [self.deviceControl subscribeToChannel: @"not-existing-channel" qos: XIDeviceControlQoSAtMostOnce];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
}
@end

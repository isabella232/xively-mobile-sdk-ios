//
//  XIMessagingE2ETests.m
//  common-iOS
//
//  Created by gszajko on 09/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "E2ETestCase.h"
#import "XISessionServices+Messaging.h"
#import "XIMessagingSubscriptionListener.h"
#import "XIMessagingDataListener.h"
#import "XITestConfig.h"

@interface XIMessagingE2ETests : E2ETestCase <XIMessagingCreatorDelegate>
@property (strong, nonatomic) id<XIMessagingCreator> messagingCreator;
@property (strong, nonatomic) XCTestExpectation* messagingCreated;
@property (strong, nonatomic) id<XIMessaging> messaging;
@end

@implementation XIMessagingE2ETests
-(void) setUp {
    [super setUp];
    self.session = [self createAccountUserSession];
    self.messagingCreated = [self expectationWithDescription: @"messagingCreated"];
    self.messagingCreator = [[self.session services] messagingCreator];
    [self.messagingCreator setDelegate: self];
    [self.messagingCreator createMessagingWithCleanSession: YES lastWill: nil];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
}

- (void)messagingCreator:(id<XIMessagingCreator>)creator didCreateMessaging:(id<XIMessaging>)messaging {
    
    self.messaging = messaging;
    [self.messagingCreated fulfill];
}

- (void)messagingCreator:(id<XIMessagingCreator>)creator didFailToCreateMessagingWithError:(NSError *)error {
    [self.messagingCreated fulfill];
}

-(void) testCreateMessagingFailedSubscription {
    
    XCTAssertNotNil(self.messaging);
    id subscriptionListener = OCMStrictProtocolMock(@protocol(XIMessagingSubscriptionListener));
    [self.messaging addSubscriptionListener: subscriptionListener];
    
    XCTestExpectation* failed = [self expectationWithDescription: @"didFailToSubscribeToChannel"];
    OCMExpect([subscriptionListener messaging: OCMOCK_ANY didFailToSubscribeToChannel: OCMOCK_ANY error: OCMOCK_ANY]).andDo(^(NSInvocation* i) {
        [failed fulfill];
    });
    
    [self.messaging subscribeToChannel: @"not-existing-channel" qos: XIMessagingQoSAtMostOnce];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    
    [self.session close];
}

- (void)testCreateMessagingSuccessfulSubscription {
    
    XCTAssertNotNil(self.messaging);
    id subscriptionListener = OCMStrictProtocolMock(@protocol(XIMessagingSubscriptionListener));
    [self.messaging addSubscriptionListener: subscriptionListener];
    
    XCTestExpectation* failed = [self expectationWithDescription: @"didFailToSubscribeToChannel"];
    OCMExpect([subscriptionListener messaging: OCMOCK_ANY didSubscribeToChannel:[OCMArg any] qos:XIMessagingQoSAtLeastOnce]).andDo(^(NSInvocation* i) {
        [failed fulfill];
    });
    
    [self.messaging subscribeToChannel: controlChannel qos: XIMessagingQoSAtLeastOnce];
    
    [self waitForExpectationsWithTimeout: 40.f handler: nil];
    
    [self.session close];
}

- (void)testCreateMessagingPublishToSubscribedChannel {
    NSString *messagingChannel = controlChannel;
    NSString *messageText = @"Hello hello";
    NSData *messageData = [messageText dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertNotNil(self.messaging);
    id subscriptionListener = OCMStrictProtocolMock(@protocol(XIMessagingSubscriptionListener));
    id dataListener = OCMStrictProtocolMock(@protocol(XIMessagingDataListener));
    [self.messaging addSubscriptionListener: subscriptionListener];
    [self.messaging addDataListener:dataListener];
    
    XCTestExpectation* failed = [self expectationWithDescription: @"didFailToSubscribeToChannel"];
    OCMExpect([subscriptionListener messaging: OCMOCK_ANY didSubscribeToChannel:[OCMArg any] qos:XIMessagingQoSAtLeastOnce]).andDo(^(NSInvocation* i) {
        
        [self.messaging publishToChannel:messagingChannel message:messageData qos:XIMessagingQoSAtLeastOnce];
        
    });
    __block BOOL messageFound = NO;
    OCMStub([dataListener messaging: OCMOCK_ANY didReceiveData:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSData *receivedData = (NSData *)obj;
        messageFound = [receivedData isEqualToData:messageData];
        return YES;
    }] onChannel:messagingChannel]).andDo(^(NSInvocation* i) {
        if(messageFound) {
            [failed fulfill];
        }
    });
    
    [self.messaging subscribeToChannel: messagingChannel qos: XIMessagingQoSAtLeastOnce];
    
    [self waitForExpectationsWithTimeout: 30.f handler: nil];
    
    [self.session close];
}

@end

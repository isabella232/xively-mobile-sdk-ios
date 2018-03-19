//
//  XIMessagingTest.m
//  common-iOS
//
//  Created by vfabian on 23/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIMessagingProxy.h"
#import "XIMSGMessaging.h"
#import "XIMessagingStateListener.h"
#import "XIMessagingDataListener.h"
#import "XIMessagingSubscriptionListener.h"

@interface XIMessagingTest : XCTestCase

@property(nonatomic, strong)XIMSGMessaging *messaging;
@property(nonatomic, strong)OCMockObject *mockMessagingProxy;
@property(nonatomic, strong)OCMockObject *mockConnection;

@property(nonatomic, strong)OCMockObject *mockDataListener1;
@property(nonatomic, strong)OCMockObject *mockDataListener2;

@property(nonatomic, strong)OCMockObject *mockStateListener1;
@property(nonatomic, strong)OCMockObject *mockStateListener2;

@property(nonatomic, strong)OCMockObject *mockSubscriptionListener1;
@property(nonatomic, strong)OCMockObject *mockSubscriptionListener2;

@property(nonatomic, strong)XCTestExpectation *expectation;

@property(nonatomic, strong)XICOSessionNotifications *notifications;

@end

@implementation XIMessagingTest

- (void)setUp {
    [super setUp];
    
    
    self.notifications = [XICOSessionNotifications new];
    self.mockMessagingProxy = [OCMockObject mockForProtocol:@protocol(XIMessaging)];
    self.mockConnection = [OCMockObject mockForProtocol:@protocol(XICOConnecting)];
    [[self.mockConnection expect] addListener:[OCMArg any]];
    self.messaging = [[XIMSGMessaging alloc] initWithLogger:nil
                                                             proxy:(id<XIMessaging>)self.mockMessagingProxy
                                                        connection:(id<XICOConnecting>)self.mockConnection
                          notifications:self.notifications];
    
    self.mockDataListener1 = [OCMockObject mockForProtocol:@protocol(XIMessagingDataListener)];
    self.mockDataListener2 = [OCMockObject mockForProtocol:@protocol(XIMessagingDataListener)];
    
    self.mockStateListener1 = [OCMockObject mockForProtocol:@protocol(XIMessagingStateListener)];
    self.mockStateListener2 = [OCMockObject mockForProtocol:@protocol(XIMessagingStateListener)];
    
    self.mockSubscriptionListener1 = [OCMockObject mockForProtocol:@protocol(XIMessagingSubscriptionListener)];
    self.mockSubscriptionListener2 = [OCMockObject mockForProtocol:@protocol(XIMessagingSubscriptionListener)];
    
    [self.messaging addDataListener:(id<XIMessagingDataListener>)self.mockDataListener1];
    [self.messaging addDataListener:(id<XIMessagingDataListener>)self.mockDataListener2];
    [self.messaging removeDataListener:(id<XIMessagingDataListener>)self.mockDataListener2];
    
    [self.messaging addStateListener:(id<XIMessagingStateListener>)self.mockStateListener1];
    [self.messaging addStateListener:(id<XIMessagingStateListener>)self.mockStateListener2];
    [self.messaging removeStateListener:(id<XIMessagingStateListener>)self.mockStateListener2];
    
    [self.messaging addSubscriptionListener:(id<XIMessagingSubscriptionListener>)self.mockSubscriptionListener1];
    [self.messaging addSubscriptionListener:(id<XIMessagingSubscriptionListener>)self.mockSubscriptionListener2];
    [self.messaging removeSubscriptionListener:(id<XIMessagingSubscriptionListener>)self.mockSubscriptionListener2];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIMSGMessagingCreation {
    XCTAssert(self.messaging, @"Creation failed");
}

- (void)testXIMSGMessagingStates {
    [(id<XICOConnecting>)[[self.mockConnection expect] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateInit)] state];
    XCTAssertEqual(XIMessagingStateClosed, self.messaging.state, @"Invalid closed state");
    [self.mockConnection verify];
    
    [(id<XICOConnecting>)[[self.mockConnection expect] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateConnected)] state];
    XCTAssertEqual(XIMessagingStateConnected, self.messaging.state, @"Invalid connected state");
    [self.mockConnection verify];
    
    [(id<XICOConnecting>)[[self.mockConnection expect] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateSuspended)] state];
    XCTAssertEqual(XIMessagingStateReconnecting, self.messaging.state, @"Invalid connected state");
    [self.mockConnection verify];
    
    [(id<XICOConnecting>)[[self.mockConnection expect] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateReconnecting)] state];
    XCTAssertEqual(XIMessagingStateReconnecting, self.messaging.state, @"Invalid connected state");
    [self.mockConnection verify];
    
    [(id<XICOConnecting>)[[self.mockConnection expect] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateError)] state];
    XCTAssertEqual(XIMessagingStateError, self.messaging.state, @"Invalid connected state");
    [self.mockConnection verify];
    
}


- (void)testXIMSGMessagingPublishWithoutRetainInInvalidState {
    [(id<XICOConnecting>)[[self.mockConnection stub] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateError)] state];
    [self.messaging publishToChannel:@"aaa" message:[NSData data] qos:XIMessagingQoSAtLeastOnce];
}

- (void)testXIMSGMessagingPublishWithoutRetainInValidState {
    NSString *messageSent = @"sdkjalfhdskjlgdshfkljdsakflsdlkjh";
    NSData *d = [messageSent dataUsingEncoding:NSUTF8StringEncoding];
    NSString *channel = @"sdlgkjsfdhgskfdlghfsdklgjh";
    NSUInteger messageId = 335;
    
    [(id<XICOConnecting>)[[self.mockConnection stub] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateConnected)] state];
    [[[self.mockConnection expect] andReturnValue:OCMOCK_VALUE(messageId)] publishData:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSData *receivedData = (NSData*)obj;
        NSString* receivedMessage = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
        return [receivedMessage isEqualToString:messageSent];
    }]
                                                                                  toTopic:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *receivedTopic = (NSString *)obj;
        return [receivedTopic isEqualToString:channel];
    }]
                                                                                  withQos:XICOQOSAtLeastOnce
                                                                                   retain:NO];
    
    NSUInteger receivedMessageId = [self.messaging publishToChannel:channel message:d qos:XIMessagingQoSAtLeastOnce];
    XCTAssertEqual(messageId, receivedMessageId, @"Invalid retreived message id");
    
    
}

- (void)testXIMSGMessagingPublishWithRetainInInvalidState {
    [(id<XICOConnecting>)[[self.mockConnection stub] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateError)] state];
    [self.messaging publishToChannel:@"aaa" message:[NSData data] qos:XIMessagingQoSAtLeastOnce retain:YES];
}

- (void)testXIMSGMessagingPublishWithRetainInValidState {
    NSString *messageSent = @"sdkjalfhdskjlgdshfkljdsakflsdlkjh";
    NSData *d = [messageSent dataUsingEncoding:NSUTF8StringEncoding];
    NSString *channel = @"sdlgkjsfdhgskfdlghfsdklgjh";
    NSUInteger messageId = 335;
    
    [(id<XICOConnecting>)[[self.mockConnection stub] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateConnected)] state];
    [[[self.mockConnection expect] andReturnValue:OCMOCK_VALUE(messageId)] publishData:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSData *receivedData = (NSData*)obj;
        NSString* receivedMessage = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
        return [receivedMessage isEqualToString:messageSent];
    }]
                                                                                  toTopic:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *receivedTopic = (NSString *)obj;
        return [receivedTopic isEqualToString:channel];
    }]
                                                                                  withQos:XICOQOSAtLeastOnce
                                                                                   retain:YES];
    
    NSUInteger receivedMessageId = [self.messaging publishToChannel:channel message:d qos:XIMessagingQoSAtLeastOnce retain:YES];
    XCTAssertEqual(messageId, receivedMessageId, @"Invalid retreived message id");
}

- (void)testXIMSGMessagingSubscribeInInvalidState {
    [(id<XICOConnecting>)[[self.mockConnection stub] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateError)] state];
    [self.messaging subscribeToChannel:@"sdgasg" qos:XIMessagingQoSAtLeastOnce];
}

- (void)testXIMSGMessagingSubscribeInValidState {
    NSString *channel = @"sdlgkjsfdhgskfdlghfsdklgjh";
    
    [(id<XICOConnecting>)[[self.mockConnection stub] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateConnected)] state];
    [[self.mockConnection expect] subscribeToTopic:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *receivedTopic = (NSString *)obj;
        return [receivedTopic isEqualToString:channel];
    }] qos:XICOQOSAtLeastOnce];
    
    [self.messaging subscribeToChannel:channel qos:XIMessagingQoSAtLeastOnce];
}

- (void)testXIMSGMessagingUnsubscribeInInvalidState {
    [(id<XICOConnecting>)[[self.mockConnection stub] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateError)] state];
    [self.messaging unsubscribeFromChannel:@"gsfgsfddfhfdh"];
}

- (void)testXIMSGMessagingUnsubscribeInValidState {
    NSString *channel = @"sdlgkjsfdhgskfdlghfsdklgjh";
    
    [(id<XICOConnecting>)[[self.mockConnection stub] andReturnValue:OCMOCK_VALUE((XICOConnectionState)XICOConnectionStateConnected)] state];
    [[self.mockConnection expect] unsubscribeFromTopic:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *receivedTopic = (NSString *)obj;
        return [receivedTopic isEqualToString:channel];
    }]];
    
    [self.messaging unsubscribeFromChannel:channel];
}

- (void)testXIMSGMessagingClose {
    __weak id<XICOConnectionListener> listener = (id<XICOConnectionListener>)self.messaging;
    [[self.mockConnection expect] removeListener:listener];
    [[self.mockConnection expect] releaseConnection];
    [self.messaging close];
    [self.mockConnection verify];
    [[self.mockStateListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didChangeStateTo:XIMessagingStateClosed];
    
    [self.messaging close];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockStateListener1 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
}

- (void)testXIMSGMessagingCloseBySessionClosed {
    __weak id<XICOConnectionListener> listener = (id<XICOConnectionListener>)self.messaging;
    [[self.mockConnection expect] removeListener:listener];
    [[self.mockConnection expect] releaseConnection];
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidCloseNotification object:nil];
    [self.mockConnection verify];
    [[self.mockStateListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didChangeStateTo:XIMessagingStateClosed];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockStateListener1 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIMSGMessagingReconnected {
    id<XICOConnectionListener> connectionListener =(id<XICOConnectionListener>)self.messaging;
    [[self.mockStateListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didChangeStateTo:XIMessagingStateConnected];
    [connectionListener connection:(id<XICOConnecting>)self.mockConnection didConnectedToBroker:nil];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockStateListener1 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIMSGMessagingReconnecting {
    id<XICOConnectionListener> connectionListener =(id<XICOConnectionListener>)self.messaging;
    [[self.mockStateListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didChangeStateTo:XIMessagingStateReconnecting];
    [connectionListener connection:(id<XICOConnecting>)self.mockConnection willReconnectToBroker:nil];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockStateListener1 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIMSGMessagingSubscribeSuccess {
    NSString *channel = @"dasfgdsakjfhgdsafkjasdfgdsakjfhgsadkjfdgh";
    id<XICOConnectionListener> connectionListener =(id<XICOConnectionListener>)self.messaging;
    [[self.mockSubscriptionListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didSubscribeToChannel:channel qos:XIMessagingQoSAtLeastOnce];
    [connectionListener connection:(id<XICOConnecting>)self.mockConnection didSubscribeToTopic:channel qos:XICOQOSAtLeastOnce];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockSubscriptionListener1 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIMSGMessagingSubscribeFail {
    NSString *channel = @"dasfgdsakjfhgdsafkjasdfgdsakjfhgsadkjfdgh";
    id<XICOConnectionListener> connectionListener =(id<XICOConnectionListener>)self.messaging;
    [[self.mockSubscriptionListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didFailToSubscribeToChannel:[OCMArg any] error:[OCMArg any]];
    [connectionListener connection:(id<XICOConnecting>)self.mockConnection didFailToSubscribeToTopic:channel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockSubscriptionListener1 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}


- (void)testXIMSGMessagingUnsubscribed {
    NSString *channel = @"dasfgdsakjfhgdsafkjasdfgdsakjfhgsadkjfdgh";
    id<XICOConnectionListener> connectionListener =(id<XICOConnectionListener>)self.messaging;
    [[self.mockSubscriptionListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didUnsubscribeFromChannel:channel];
    [connectionListener connection:(id<XICOConnecting>)self.mockConnection didUnsubscribeFromTopic:channel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockSubscriptionListener1 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIMSGMessagingReceivePuback {
    NSString *channel = @"dasfgdsakjfhgdsafkjasdfgdsakjfhgsadkjfdgh";
    NSString *message = @"k45jl6h435lk6jh46klj5h6kl543jh";
    NSData* data = [message dataUsingEncoding: NSUTF8StringEncoding];
    NSUInteger messageId = 3452;
    id<XICOConnectionListener> connectionListener =(id<XICOConnectionListener>)self.messaging;
    [[self.mockDataListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didSendDataWithId:messageId];
    [connectionListener connection:(id<XICOConnecting>)self.mockConnection  didReceivePublishAckFromTopic:channel withData:data messageId:messageId];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDataListener1 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIMSGMessagingReceiveMessage {
    NSString *channel = @"dasfgdsakjfhgdsafkjasdfgdsakjfhgsadkjfdgh";
    NSString *message = @"k45jl6h435lk6jh46klj5h6kl543jh";
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];

    id<XICOConnectionListener> connectionListener =(id<XICOConnectionListener>)self.messaging;
    [[self.mockDataListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didReceiveData:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSData *receivedData = (NSData *)obj;
        return [receivedData isEqualToData:data];
    }] onChannel:channel];
    [connectionListener connection:(id<XICOConnecting>)self.mockConnection didReceiveData:data fromTopic:channel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDataListener1 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIMSGMessagingConnectionError {
    NSError *error = [NSError errorWithDomain:@"sdgsd" code:78 userInfo:nil];
    
    id<XICOConnectionListener> connectionListener =(id<XICOConnectionListener>)self.messaging;
    [[self.mockStateListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy willEndWithError:error];
    [[self.mockStateListener1 expect] messaging:(id<XIMessaging>)self.mockMessagingProxy didChangeStateTo:XIMessagingStateError];
    [connectionListener connection:(id<XICOConnecting>)self.mockConnection didFailToConnect:error];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockStateListener1 verify];
        XCTAssertEqual(self.messaging.finalError, error, @"Final error error");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIMessagingProxyCreation {
    XIMessagingProxy *proxy = [[XIMessagingProxy alloc] initWithInternal:(id<XIMessaging>)self.messaging];
    XCTAssert(proxy, @"Proxy creation failed");
}

- (void)testXIMessagingProxyProxing {
    OCMockObject *mockMessaging = [OCMockObject mockForProtocol:@protocol(XIMessaging)];
    XIMessagingProxy *proxy = [[XIMessagingProxy alloc] initWithInternal:(id<XIMessaging>)mockMessaging];
    
    [(id<XICOConnecting>)[[mockMessaging expect] andReturnValue:OCMOCK_VALUE(XIMessagingStateReconnecting)] state];
    XCTAssertEqual(XIMessagingStateReconnecting, proxy.state, @"Invalid state");
    [mockMessaging verify];
    
    NSError *error = [NSError errorWithDomain:@"sdgsd" code:78 userInfo:nil];
    [[[mockMessaging expect] andReturn:error] finalError];
    XCTAssertEqual(error, proxy.finalError, @"Invalid state");
    [mockMessaging verify];
    
    [[mockMessaging expect] addDataListener:(id<XIMessagingDataListener>)self.mockDataListener1];
    [proxy addDataListener:(id<XIMessagingDataListener>)self.mockDataListener1];
    [mockMessaging verify];
    
    [[mockMessaging expect] removeDataListener:(id<XIMessagingDataListener>)self.mockDataListener1];
    [proxy removeDataListener:(id<XIMessagingDataListener>)self.mockDataListener1];
    [mockMessaging verify];
    
    [[mockMessaging expect] addStateListener:(id<XIMessagingStateListener>)self.mockStateListener1];
    [proxy addStateListener:(id<XIMessagingStateListener>)self.mockStateListener1];
    [mockMessaging verify];
    
    [[mockMessaging expect] removeStateListener:(id<XIMessagingStateListener>)self.mockStateListener1];
    [proxy removeStateListener:(id<XIMessagingStateListener>)self.mockStateListener1];
    [mockMessaging verify];
    
    [[mockMessaging expect] addSubscriptionListener:(id<XIMessagingSubscriptionListener>)self.mockSubscriptionListener1];
    [proxy addSubscriptionListener:(id<XIMessagingSubscriptionListener>)self.mockSubscriptionListener1];
    [mockMessaging verify];
    
    [[mockMessaging expect] removeSubscriptionListener:(id<XIMessagingSubscriptionListener>)self.mockSubscriptionListener1];
    [proxy removeSubscriptionListener:(id<XIMessagingSubscriptionListener>)self.mockSubscriptionListener1];
    [mockMessaging verify];
    
    NSString *channel = @"sdagdsljkghdskljgsdgkjh";
    NSData *message = [@"kl453g234kl5g4325jkh3g534jk2hg342kjhg36jk354g6jh" dataUsingEncoding:NSUTF8StringEncoding];
    [[mockMessaging expect] publishToChannel:channel message:message qos:XIMessagingQoSAtMostOnce];
    [proxy publishToChannel:channel message:message qos:XIMessagingQoSAtMostOnce];
    [mockMessaging verify];
    
    [[mockMessaging expect] publishToChannel:channel message:message qos:XIMessagingQoSAtMostOnce retain:YES];
    [proxy publishToChannel:channel message:message qos:XIMessagingQoSAtMostOnce retain:YES];
    [mockMessaging verify];
    
    [[mockMessaging expect] subscribeToChannel:channel qos:XIMessagingQoSAtMostOnce];
    [proxy subscribeToChannel:channel qos:XIMessagingQoSAtMostOnce];
    [mockMessaging verify];
    
    [[mockMessaging expect] unsubscribeFromChannel:channel];
    [proxy unsubscribeFromChannel:channel];
    [mockMessaging verify];
    
    [[mockMessaging expect] close];
    [proxy close];
    [mockMessaging verify];
}

@end

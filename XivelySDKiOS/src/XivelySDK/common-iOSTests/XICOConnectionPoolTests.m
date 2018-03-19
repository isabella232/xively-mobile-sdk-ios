//
//  XICOConnectionPoolTests.m
//  common-iOS
//
//  Created by gszajko on 27/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIAccess.h"
#import "XIServicesConfig.h"
#import <XivelySDK/XICommonError.h>
#import <Internals/Session/XICOSessionNotifications.h>
#import <XivelySDK/Messaging/XIMessagingError.h>

@interface XICOConnectionPool () <XICOConnectionListener>
@end

@interface XICOConnectionPoolTests : XCTestCase
@property(nonatomic, strong) XICOConnectionPool* pool;
@property(nonatomic, strong) XIAccess *access;
@property(nonatomic, strong) id mockConfig;
@property(nonatomic, strong) id mockConnectionFactory;
@property(nonatomic, strong) id mockConnection;
@property(nonatomic, strong) id mockDelegate;
@property(nonatomic, strong) id mockDelegate2;
@property(nonatomic, strong) id mockDelegate3;
@property(nonatomic, strong) id mockDelegate4;
@property(nonatomic, strong) id mockCreateMqttCredentials;
@property(nonatomic, strong) id mockCreateMqttCredentialsProvider;
@property(nonatomic, strong) XIServicesConfig *servicesConfig;

@property(nonatomic, strong) id<XICOConnectionPoolCancelable> cancelable1;
@property(nonatomic, strong) id<XICOConnectionPoolCancelable> cancelable2;
@property(nonatomic, strong) id<XICOConnectionPoolCancelable> cancelable3;
@property(nonatomic, strong) id<XICOConnectionPoolCancelable> cancelable4;

@property(nonatomic, strong) XCTestExpectation *expectation;
@property(nonatomic, strong) NSString *mqttUsername;
@property(nonatomic, strong) NSString *mqttPassword;
@property(nonatomic, strong) XICOSessionNotifications *notifications;

@property(nonatomic, strong) XILastWill* lastWill;
@end

@implementation XICOConnectionPoolTests

- (void)setUp {
    [super setUp];
    
    self.notifications = [XICOSessionNotifications new];
    
    self.access = [XIAccess new];
    self.access.blueprintUserType = XIAccessBlueprintUserTypeEndUser;
    self.access.accountId = @"sdkgjsdhgklshgkdgdsfkgjh";
    self.mqttPassword = self.access.mqttPassword = @"sdkghjgfjhgfhgfjsdhgklshgkdgdsfkgjh";
    self.access.mqttDeviceId = @"sdkghjgfhjgfhgfghjfhgfjsdhgklshgkdgdsfkgjh";
    self.access.jwt = @"sdkljghsdalkgjhgrkl4jh35k435jh34kl5j324h5lk345jh";
    self.mqttUsername = self.access.blueprintUserId = @"sdkgjsdhgklshgkdgdsfkgjh";
    
    self.servicesConfig = [[XIServicesConfig alloc] initWithSdkConfig:[[XISdkConfig alloc] init]];
    
    _mockConfig = OCMStrictClassMock([XISdkConfig class]);
    _mockConnectionFactory = OCMStrictClassMock([XICOConnectionFactory class]);
    _mockConnection = OCMStrictClassMock([XICOConnection class]);
    _mockDelegate = OCMStrictProtocolMock(@protocol(XICOConnectionPoolDelegate));
    _mockDelegate2 = OCMStrictProtocolMock(@protocol(XICOConnectionPoolDelegate));
    _mockDelegate3 = OCMStrictProtocolMock(@protocol(XICOConnectionPoolDelegate));
    _mockDelegate4 = OCMStrictProtocolMock(@protocol(XICOConnectionPoolDelegate));
    self.mockCreateMqttCredentials = [OCMockObject mockForProtocol:@protocol(XICOCreateMqttCredentialsCall)];
    self.mockCreateMqttCredentialsProvider = [OCMockObject mockForProtocol:@protocol(XICOCreateMqttCredentialsCallProvider)];
    
    _pool = [[XICOConnectionPool alloc] initWithAccess: self.access
                                        servicesConfig: self.servicesConfig
                                     connectionFactory: _mockConnectionFactory
                                                logger: nil
             createMqttCredentialsCallProvider:(id<XICOCreateMqttCredentialsCallProvider>)self.mockCreateMqttCredentialsProvider
             notifications:self.notifications];
    
    self.lastWill = [[XILastWill alloc] initWithChannel: @"topic"
                                              message: [@"message" dataUsingEncoding: NSUTF8StringEncoding]
                                                  qos: XIMessagingQoSAtLeastOnce
                                               retain: YES];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreation {
    XCTAssert(_pool, @"Pool Creation failed");
}

- (void)testFirstConnectionRequestForEndUser {
    
    [[[self.mockCreateMqttCredentialsProvider expect] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials expect] setDelegate:[OCMArg any]];
    
    [[self.mockCreateMqttCredentials expect] requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    
    self.cancelable1 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate];
    
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
}

- (void)testFirstConnectionRequestForAccountUser {
    self.access.blueprintUserType = XIAccessBlueprintUserTypeAccountUser;
    [[[self.mockCreateMqttCredentialsProvider expect] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials expect] setDelegate:[OCMArg any]];
    
    [[self.mockCreateMqttCredentials expect] requestWithAccountUserId:self.access.blueprintUserId accountId:self.access.accountId];
    
    self.cancelable1 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate: self.mockDelegate];
    
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
}

- (void)testFirstConnectionRequest_otherRequestComesWithOtherParams {
    
    [[[self.mockCreateMqttCredentialsProvider expect] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials expect] setDelegate:[OCMArg any]];
    
    [[self.mockCreateMqttCredentials expect] requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    
    self.cancelable1 = [_pool requestConnectionWithDelegate:self.mockDelegate];
    
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
    
    [[self.mockDelegate2 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError *)obj;
        return error.code == XIMessagingErrorInvalidConnectParameters;
    }]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testFirstConnectionRequest_otherRequestsComeWithOtherParams {
    
    [[[self.mockCreateMqttCredentialsProvider expect] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials expect] setDelegate:[OCMArg any]];
    
    [[self.mockCreateMqttCredentials expect] requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    
    self.cancelable1 = [_pool requestConnectionWithDelegate:self.mockDelegate];
    
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
    
    [[self.mockDelegate2 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockDelegate3 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.cancelable3 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate3];
    
    
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.mockDelegate3 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testFirstConnectionRequest_otherRequestsComeWithOtherParamsAndAllCancel {
    
    [[[self.mockCreateMqttCredentialsProvider expect] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials expect] setDelegate:[OCMArg any]];
    
    [[self.mockCreateMqttCredentials expect] requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    
    self.cancelable1 = [_pool requestConnectionWithDelegate:self.mockDelegate];
    
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
    
    [[self.mockDelegate2 reject] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockDelegate3 reject] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.cancelable3 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate3];
    
    
    [self.cancelable2 cancel];
    [self.cancelable3 cancel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.mockDelegate3 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testFirstConnectionRequest_otherRequestsComeWithOtherParamsAndFewCancel {
    
    [[[self.mockCreateMqttCredentialsProvider expect] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials expect] setDelegate:[OCMArg any]];
    
    [[self.mockCreateMqttCredentials expect] requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    
    self.cancelable1 = [_pool requestConnectionWithDelegate:self.mockDelegate];
    
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
    
    [[self.mockDelegate2 reject] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockDelegate3 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.cancelable3 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate3];
    
    
    [self.cancelable2 cancel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.mockDelegate3 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testFirstConnectionRequest_mqttCredentialsGetFails {
    [self testFirstConnectionRequestForEndUser];
    NSError *error = [NSError errorWithDomain:@"fsgsdfg" code:987 userInfo:nil];
    
    [[self.mockDelegate expect] connectionPool:self.pool didFailToCreateConnection:error];
    
    [(id<XICOCreateMqttCredentialsCallDelegate>)_pool createMqttCredentialsCall:nil
                                                               didFailWithError:error];
    [self.mockDelegate verify];

    //test if the pool can be restarted
    [self testFirstConnectionRequestForEndUser];
}

- (void)testFirstConnectionRequest_otherConnectionRequestedWhileMqttCredentialsRequested {
    [self testFirstConnectionRequestForEndUser];
    self.cancelable2 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
}

- (void)testFirstConnectionRequest_andCanceled {
    [self testFirstConnectionRequestForEndUser];
    
    [[self.mockCreateMqttCredentials expect] cancel];
    
    [self.cancelable1 cancel];
    
    [self.mockDelegate verify];
    
    //test if the pool can be restarted
    [self testFirstConnectionRequestForEndUser];
}

- (void)test2ConnectingAndOneCancels {
    [self testFirstConnectionRequest_otherConnectionRequestedWhileMqttCredentialsRequested];
    
    [[self.mockCreateMqttCredentials reject] cancel];
    
    [self.cancelable1 cancel];
    
    [self.mockDelegate verify];
}

- (void)test2ConnectingAnd2Cancels {
    [self testFirstConnectionRequest_otherConnectionRequestedWhileMqttCredentialsRequested];
    
    [[self.mockCreateMqttCredentials expect] cancel];
    [self.cancelable1 cancel];
    [self.mockDelegate verify];
}

- (void)testMqttCredentialsReceived {
    [self testFirstConnectionRequest_otherConnectionRequestedWhileMqttCredentialsRequested];
    
    [[[self.mockConnectionFactory expect] andReturn:self.mockConnection] createConnectionWithLogger: [OCMArg any]
                                                                                     connectionPool: [OCMArg any]];
    [[self.mockConnection expect] addListener: [OCMArg any]];
    [[self.mockConnection expect] connectWithUrl: [OCMArg any]
                                        username: self.mqttUsername
                                        password: self.mqttPassword
                                    cleanSession: YES
                                        lastWill: [OCMArg any]];
    
    [(id<XICOCreateMqttCredentialsCallDelegate>)_pool createMqttCredentialsCall: nil
                                                     didSucceedWithMqttUserName: self.mqttUsername
                                                                   mqttPassword: self.mqttPassword];
    
    [self.mockConnectionFactory verify];
    [self.mockConnection verify];
    
    XCTAssert([self.mqttUsername isEqualToString:self.access.mqttUsername], @"XIAccess mqtt override fails");
    XCTAssert([self.mqttPassword isEqualToString:self.access.mqttPassword], @"XIAccess mqtt override fails");
}

- (void)testConnectingToMqttAndAddNewRequest {
    [self testMqttCredentialsReceived];
    self.cancelable3 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate: self.mockDelegate3];
}

- (void)testConnectingToMqtt_reqestBadConnections {
    [self testMqttCredentialsReceived];
    
    [[self.mockDelegate2 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockDelegate3 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.cancelable3 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: nil
                                                       delegate:self.mockDelegate3];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.mockDelegate3 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testConnectingToMqtt_reqestBadConnectionsFewCancels {
    [self testMqttCredentialsReceived];
    
    [[self.mockDelegate2 reject] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockDelegate3 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.cancelable3 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: nil
                                                       delegate:self.mockDelegate3];
    
    [self.cancelable2 cancel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.mockDelegate3 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testConnectingToMqtt_reqestBadConnectionsAllCancels {
    [self testMqttCredentialsReceived];
    
    [[self.mockDelegate2 reject] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockDelegate3 reject] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.cancelable3 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: nil
                                                       delegate:self.mockDelegate3];
    
    [self.cancelable2 cancel];
    [self.cancelable3 cancel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.mockDelegate3 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testConnectingToMqttAndCancels {
    [self testConnectingToMqttAndAddNewRequest];
    [self.cancelable1 cancel];
    [self.cancelable2 cancel];
    
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    [[self.mockConnection expect] disconnect];
    
    [self.cancelable3 cancel];
    
    [self.mockConnection verify];
}

- (void)testConnectingToMqttFailsWithError {
    [self testConnectingToMqttAndAddNewRequest];
    NSError *error = [NSError errorWithDomain:@"dsgsdg" code:987 userInfo:nil];
    [[self.mockDelegate expect] connectionPool:self.pool didFailToCreateConnection:error];
    [[self.mockDelegate2 expect] connectionPool:self.pool didFailToCreateConnection:error];
    [[self.mockDelegate3 expect] connectionPool:self.pool didFailToCreateConnection:error];
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didFailToConnect:error];
    
    [self.mockConnection verify];
    [self.mockDelegate verify];
    [self.mockDelegate2 verify];
    [self.mockDelegate3 verify];
}

- (void)testConnectingConnected {
    [self testConnectingToMqttAndAddNewRequest];
    
    [[self.mockDelegate expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate2 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate3 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    
    [self.mockDelegate verify];
    [self.mockDelegate2 verify];
    [self.mockDelegate3 verify];
}

- (void)testConnected_reqestBadConnections {
    [self testConnectingConnected];
    
    [[self.mockDelegate2 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockDelegate3 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.cancelable3 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: nil
                                                       delegate:self.mockDelegate3];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.mockDelegate3 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testConnected_reqestBadConnectionsFewCancels {
    [self testConnectingConnected];
    
    [[self.mockDelegate2 reject] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockDelegate3 expect] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.cancelable3 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: nil
                                                       delegate:self.mockDelegate3];
    
    [self.cancelable2 cancel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.mockDelegate3 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testConnected_reqestBadConnectionsAllCancels {
    [self testConnectingConnected];
    
    [[self.mockDelegate2 reject] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockDelegate3 reject] connectionPool:_pool didFailToCreateConnection:[OCMArg any]];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: NO
                                                       lastWill: self.lastWill
                                                       delegate:self.mockDelegate2];
    
    self.cancelable3 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: nil
                                                       delegate:self.mockDelegate3];
    
    [self.cancelable2 cancel];
    [self.cancelable3 cancel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate2 verify];
        [self.mockDelegate3 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testConnected_requestConnection {
    [self testConnectingToMqttAndAddNewRequest];
    
    [[self.mockDelegate expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate2 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate3 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    
    [self.mockDelegate verify];
    [self.mockDelegate2 verify];
    [self.mockDelegate3 verify];
    
    [[self.mockDelegate4 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    self.cancelable4 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate: self.mockDelegate4];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate4 verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testConnected_cancelNotAllConnections {
    [self testConnectingToMqttAndAddNewRequest];
    
    [[self.mockDelegate expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate2 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate3 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    
    [self.mockConnection verify];
    [self.mockDelegate verify];
    [self.mockDelegate2 verify];
    [self.mockDelegate3 verify];
    
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    [[self.mockConnection expect] disconnect];
    
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];
    
    [self.mockConnection verify];
    [self.expectation fulfill];
}

- (void)testConnected_cancelAllConnections {
    [self testConnectingToMqttAndAddNewRequest];
    
    [[self.mockDelegate expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate2 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate3 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    
    [self.mockConnection verify];
    [self.mockDelegate verify];
    [self.mockDelegate2 verify];
    [self.mockDelegate3 verify];
    
    [[self.mockConnection reject] removeListener:[OCMArg any]];
    [[self.mockConnection reject] disconnect];
    
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];

    [self.mockConnection verify];
}

- (void)testConnected_cancelAllWhileCreatingAndJustAfterCancelingAnOther {
    [self testConnectingToMqttAndAddNewRequest];
    
    [[self.mockDelegate expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate2 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate3 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    
    [self.mockConnection verify];
    [self.mockDelegate verify];
    [self.mockDelegate2 verify];
    [self.mockDelegate3 verify];
    
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    [[self.mockConnection expect] disconnect];
    
    self.cancelable4 = [self.pool requestConnectionWithCleanSession: YES
                                                           lastWill: self.lastWill
                                                           delegate: self.mockDelegate4];
    
    [self.cancelable4 cancel];
    
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];

    [self.mockConnection verify];
}

- (void)testConnected_cancelAllWhileCreatingAndJustAfterCancelingAnOther_cancelCreationTriggers {
    [self testConnectingToMqttAndAddNewRequest];
    
    [[self.mockDelegate expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate2 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate3 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    
    [self.mockConnection verify];
    [self.mockDelegate verify];
    [self.mockDelegate2 verify];
    [self.mockDelegate3 verify];
    
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    [[self.mockConnection expect] disconnect];
    
    self.cancelable4 = [self.pool requestConnectionWithCleanSession: YES
                                                           lastWill: self.lastWill
                                                           delegate: self.mockDelegate4];
    
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];
    
    [self.cancelable4 cancel];

    [self.mockConnection verify];
}

- (void)testConnected_ongoingConnectionFails {
    [self testConnectingToMqttAndAddNewRequest];
    
    [[self.mockDelegate expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate2 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    [[self.mockDelegate3 expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    NSError *error = [NSError errorWithDomain:@"dsgsdg" code:987 userInfo:nil];
    [self.mockConnection verify];
    [self.mockDelegate verify];
    [self.mockDelegate2 verify];
    [self.mockDelegate3 verify];
    
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didFailToConnect:error];
    [self.mockConnection verify];
    
    //test if new connection is started on new request
    [self testFirstConnectionRequestForEndUser];
}

- (void)testSuspendedIdleRequestConnection {
    [self suspendPool];
    
    [[[self.mockCreateMqttCredentialsProvider reject] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials reject] setDelegate:[OCMArg any]];
    
    [[self.mockCreateMqttCredentials reject] requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    
    self.cancelable1 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate: self.mockDelegate];
    
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
}

- (void)testSuspendedIdleRequestConnectionThanResume {
    [self suspendPool];
    
    self.cancelable1 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate: self.mockDelegate];
    
    [[[self.mockCreateMqttCredentialsProvider expect] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials expect] setDelegate:[OCMArg any]];
    [[self.mockCreateMqttCredentials expect] requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    [self resumePool];
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
}

- (void)testMqttCredentialsGetAndSuspend {
    [self testFirstConnectionRequestForEndUser];
    [[self.mockCreateMqttCredentials expect] cancel];
    [self suspendPool];
    [self.mockCreateMqttCredentials verify];
}

- (void)testSuspendedMqttCredentialsResume {
    [self testMqttCredentialsGetAndSuspend];
    
    [[[self.mockCreateMqttCredentialsProvider expect] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials expect] setDelegate:[OCMArg any]];
    [[self.mockCreateMqttCredentials expect] requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    [self resumePool];
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
}

- (void)testSuspendedMqttCredentialsAddAConnectionAndResume {
    [self testMqttCredentialsGetAndSuspend];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate: self.mockDelegate2];
    
    [[[self.mockCreateMqttCredentialsProvider expect] andReturn:self.mockCreateMqttCredentials] createMqttCredentialsCall];
    [[self.mockCreateMqttCredentials expect] setDelegate:[OCMArg any]];
    [[self.mockCreateMqttCredentials expect] requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    [self resumePool];
    [self.mockCreateMqttCredentialsProvider verify];
    [self.mockCreateMqttCredentials verify];
}

- (void)testSuspendedMqttCredentialsRemoveAllConnectionAndResume {
    [self testMqttCredentialsGetAndSuspend];
    
    [self.cancelable1 cancel];
    
    [self resumePool];
}

- (void)testCreateConnectionSuspend {
    [self testMqttCredentialsReceived];
    
    [self suspendPool];
}

- (void)testSuspendedCreateConnectionResume {
    [self testCreateConnectionSuspend];
    [self resumePool];
}


- (void)testSuspendedCreateConnectionAddAndRemoveConnection {
    [self testCreateConnectionSuspend];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate: self.mockDelegate2];
    
    [self.cancelable1 cancel];
    [self.cancelable2 cancel];
    
    [self resumePool];
}

- (void)testRunningModeSuspend {
    [self testConnectingConnected];
    
    [self suspendPool];
}

- (void)testSuspendedRunningModeResume {
    [self testRunningModeSuspend];
    
    [self resumePool];
}

- (void)testSuspendedRunningModeAddAndRemoveConnection {
    [self testRunningModeSuspend];
    
    self.cancelable2 = [_pool requestConnectionWithCleanSession: YES
                                                       lastWill: self.lastWill
                                                       delegate: self.mockDelegate2];
    
    [self.cancelable1 cancel];
    [self.cancelable2 cancel];
    
    [self resumePool];
}

- (void)testSuspendedRunningModeCancelReceivedConnection {
    [self testRunningModeSuspend];
    [self.pool releaseConnection:self.mockConnection];
    [self resumePool];
}

- (void)testResumingConnectedWithValidConnection {
    [self testRunningModeSuspend];
    [self resumePool];
    OCMockObject *mockNewDelegate = [OCMockObject mockForProtocol:@protocol(XICOConnectionPoolDelegate)];
    
    [[mockNewDelegate expect] connectionPool:self.pool didCreateConnection:self.mockConnection];
    
    /*id<XICOConnectionPoolCancelable> newCancelable =*/ [_pool requestConnectionWithCleanSession: YES
                                                                                  lastWill: self.lastWill
                                                                                  delegate: (id<XICOConnectionPoolDelegate>)mockNewDelegate];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    [mockNewDelegate verify];
}

- (void)testResumingConnectedWithInvalidConnection {
    [self testRunningModeSuspend];
    [self resumePool];
    OCMockObject *mockNewDelegate = [OCMockObject mockForProtocol:@protocol(XICOConnectionPoolDelegate)];
    OCMockObject *mockOtherConnection = [OCMockObject mockForClass:[XICOConnection class]];
    [[mockNewDelegate reject] connectionPool:self.pool didCreateConnection:self.mockConnection];
    
    /*id<XICOConnectionPoolCancelable> newCancelable =*/ [_pool requestConnectionWithCleanSession: YES
                                                                                         lastWill: self.lastWill
                                                                                         delegate: (id<XICOConnectionPoolDelegate>)mockNewDelegate];
    
    [(id<XICOConnectionListener>)self.pool connection:(XICOConnection *)mockOtherConnection didConnectedToBroker:nil];
    [mockNewDelegate verify];
}

- (void)testResumingFailedToConnectWithValidConnection {
    [self testRunningModeSuspend];
    [self resumePool];
    OCMockObject *mockNewDelegate = [OCMockObject mockForProtocol:@protocol(XICOConnectionPoolDelegate)];
    
    [[mockNewDelegate expect] connectionPool:self.pool didFailToCreateConnection:[OCMArg any]];
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    
    /*id<XICOConnectionPoolCancelable> newCancelable =*/ [_pool requestConnectionWithCleanSession: YES
                                                                                         lastWill: self.lastWill
                                                                                         delegate: (id<XICOConnectionPoolDelegate>)mockNewDelegate];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didFailToConnect:[NSError errorWithDomain:@"" code:0 userInfo:nil]];
    [mockNewDelegate verify];
}

- (void)testResumingFailedToConnectWithInvalidConnection {
    [self testRunningModeSuspend];
    [self resumePool];
    OCMockObject *mockNewDelegate = [OCMockObject mockForProtocol:@protocol(XICOConnectionPoolDelegate)];
    OCMockObject *mockOtherConnection = [OCMockObject mockForClass:[XICOConnection class]];
    /*id<XICOConnectionPoolCancelable> newCancelable =*/ [_pool requestConnectionWithCleanSession: YES
                                                                                         lastWill: self.lastWill
                                                                                         delegate: (id<XICOConnectionPoolDelegate>)mockNewDelegate];
    
    [(id<XICOConnectionListener>)self.pool connection:(XICOConnection *)mockOtherConnection didFailToConnect:[NSError errorWithDomain:@"" code:0 userInfo:nil]];
    [mockNewDelegate verify];
}

- (void)testResumingAndRequestConnectionAndCancel {
    [self testRunningModeSuspend];
    [self resumePool];
    OCMockObject *mockNewDelegate = [OCMockObject mockForProtocol:@protocol(XICOConnectionPoolDelegate)];
    
    id<XICOConnectionPoolCancelable> newCancelable = [_pool requestConnectionWithCleanSession: YES
                                                                                         lastWill: self.lastWill
                                                                                         delegate: (id<XICOConnectionPoolDelegate>)mockNewDelegate];
    
    [newCancelable cancel];
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    [mockNewDelegate verify];
}

- (void)testResumingAndRequestConnectionAndCancelToCloseTheConnection {
    [self testRunningModeSuspend];
    [self resumePool];
    OCMockObject *mockNewDelegate = [OCMockObject mockForProtocol:@protocol(XICOConnectionPoolDelegate)];
    
    id<XICOConnectionPoolCancelable> newCancelable = [_pool requestConnectionWithCleanSession: YES
                                                                                     lastWill: self.lastWill
                                                                                     delegate: (id<XICOConnectionPoolDelegate>)mockNewDelegate];
    
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];
    
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    [[self.mockConnection expect] disconnect];

    [newCancelable cancel];
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    [mockNewDelegate verify];
    [self.mockConnection verify];
}

- (void)testResumingDuringCloseTheConnection {
    [self testRunningModeSuspend];
    [self resumePool];
    OCMockObject *mockNewDelegate = [OCMockObject mockForProtocol:@protocol(XICOConnectionPoolDelegate)];
    
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];
    
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    [[self.mockConnection expect] disconnect];
    
    [self.pool releaseConnection:self.mockConnection];
    
    [(id<XICOConnectionListener>)self.pool connection:self.mockConnection didConnectedToBroker:nil];
    [mockNewDelegate verify];
    [self.mockConnection verify];
}

- (void)testResumingRequestInvalidConnection {
    [self testRunningModeSuspend];
    [self resumePool];
    OCMockObject *mockNewDelegate = [OCMockObject mockForProtocol:@protocol(XICOConnectionPoolDelegate)];
    
    [[mockNewDelegate expect] connectionPool:[OCMArg any] didFailToCreateConnection:[OCMArg any]];
    
    /*id<XICOConnectionPoolCancelable> newCancelable =*/ [_pool requestConnectionWithCleanSession: NO
                                                                                     lastWill: self.lastWill
                                                                                     delegate: (id<XICOConnectionPoolDelegate>)mockNewDelegate];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [mockNewDelegate verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testResumingRequestInvalidConnectionAndCancel {
    [self testRunningModeSuspend];
    [self resumePool];
    OCMockObject *mockNewDelegate = [OCMockObject mockForProtocol:@protocol(XICOConnectionPoolDelegate)];
    
    id<XICOConnectionPoolCancelable> newCancelable = [_pool requestConnectionWithCleanSession: NO
                                                                                         lastWill: self.lastWill
                                                                                         delegate: (id<XICOConnectionPoolDelegate>)mockNewDelegate];
    
    
    [newCancelable cancel];
    
    [self.pool releaseConnection:self.mockConnection];
    [self.pool releaseConnection:self.mockConnection];
    
    [[self.mockConnection expect] removeListener:[OCMArg any]];
    [[self.mockConnection expect] disconnect];
    
    [self.pool releaseConnection:self.mockConnection];
    
    
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

//==========================================================================================



- (void)testMqttCredentialsGetAndClose {
    [self testFirstConnectionRequestForEndUser];
    [[self.mockCreateMqttCredentials expect] cancel];
    [self closePool];
    [self.mockCreateMqttCredentials verify];
}

- (void)testCreateConnectionClose {
    [self testMqttCredentialsReceived];
    
    [[self.mockConnection expect] disconnect];
    [self closePool];
    [self.mockConnection verify];
}

- (void)testRunningModeClose {
    [self testConnectingConnected];
    
    [[self.mockConnection expect] disconnect];
    [self closePool];
    [self.mockConnection verify];
}

#pragma mark -
#pragma mark Suspend resume

- (void)suspendPool {
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidSuspendNotification object:nil];
}

- (void)resumePool {
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidResumeNotification object:nil];
}

- (void)closePool {
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidCloseNotification object:nil];
}

@end

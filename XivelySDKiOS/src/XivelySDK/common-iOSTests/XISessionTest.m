//
//  XISessionImplTest.m
//  common-iOS
//
//  Created by vfabian on 14/01/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "XIAccess.h"
#import "XISessionProxy.h"
#import "XISession.h"
#import "XISessionServicesInternal.h"
#import <XivelySDK/XICommonError.h>
#import "XISessionInternal.h"
#import <XivelySDK/XISdkConfig.h>
#import "XIServicesConfig.h"
#import "XICOConnectionPool.h"

@interface XINotificationReceiver : NSObject

@property(nonatomic, assign)BOOL suspendNotificationFired;
@property(nonatomic, assign)BOOL resumeNotificationFired;
@property(nonatomic, assign)BOOL closeNotificationFired;

@end

@implementation XINotificationReceiver

- (void)suspended:(NSNotification *)notification {
    self.suspendNotificationFired = YES;
}

- (void)resumed:(NSNotification *)notification {
    self.resumeNotificationFired = YES;
}

- (void)closed:(NSNotification *)notification {
    self.closeNotificationFired = YES;
}

@end


@interface XISessionTest : XCTestCase

@property(nonatomic, strong)XIAccess *access;
@property(nonatomic, strong)XISessionInternal *session;
@property(nonatomic, strong)XIServicesConfig *servicesConfig;
@property(nonatomic, strong)id<XICOConnectionPooling> connectionPool;
@property(nonatomic, strong)XINotificationReceiver *notificationReceiver;

@end

@implementation XISessionTest

@synthesize access = _access;
@synthesize session = _session;
@synthesize servicesConfig = _servicesConfig;

- (void)setUp {
    NSString *password = @"password";
    NSString *deviceId = @"device id";
    NSString *accountId = @"gfd-hg-dfhf-h-hfd-h-fhdf-h-fh-gfnj-fj-ytjm-yj-yj-tf";
    NSString *jwt = @"k45l6g54kl6g346ljh54g65j4h6g435jkhg6jh5g6j";
    
    self.access = [[XIAccess alloc] init];
    self.access.accountId = accountId;
    self.access.mqttPassword = password;
    self.access.mqttDeviceId = deviceId;
    self.access.jwt = jwt;
    self.servicesConfig = [[XIServicesConfig alloc] initWithSdkConfig: [XISdkConfig config]];
    
    self.session = [[XISessionInternal alloc] initWithLogger:nil
                                            restCallProvider:(id<XIRESTCallProvider>)[NSObject new]
                                              servicesConfig:self.servicesConfig
                                                      access:self.access];
    
    self.connectionPool = (id<XICOConnectionPooling>)[OCMockObject mockForProtocol:@protocol(XICOConnectionPooling)];
    
    self.notificationReceiver = [XINotificationReceiver new];
    
    [self.session.notifications.sessionNotificationCenter addObserver:self.notificationReceiver
                                                             selector:@selector(suspended:)
                                                                 name:XISessionDidSuspendNotification
                                                               object:nil];
    
    [self.session.notifications.sessionNotificationCenter addObserver:self.notificationReceiver
                                                             selector:@selector(resumed:)
                                                                 name:XISessionDidResumeNotification
                                                               object:nil];
    
    [self.session.notifications.sessionNotificationCenter addObserver:self.notificationReceiver
                                                             selector:@selector(closed:)
                                                                 name:XISessionDidCloseNotification
                                                               object:nil];
    
}

- (void)tearDown {
    [self.session.notifications.sessionNotificationCenter removeObserver:self.notificationReceiver];
    [super tearDown];
}

- (void)testSessionInternalCreation {
    XISessionInternal *session = [[XISessionInternal alloc] initWithLogger:nil
                                                                         restCallProvider:(id<XIRESTCallProvider>)[NSObject new]
                                                                           servicesConfig:self.servicesConfig
                                                                                   access:self.access];
    XCTAssert(session, @"Session creation failed");
    XCTAssert(session.services, @"Services creation failed");
    XCTAssertEqual(session.state, XISessionStateActive, @"Initial state is not correct");
    XCTAssertEqual(self.access, session.access, @"Invalid access setting");
}

- (void)testSessionInternalStaticCreation {
    XISessionInternal *session = [[XISessionInternal alloc] initWithLogger:nil
                                                          restCallProvider:(id<XIRESTCallProvider>)[NSObject new]
                                                            servicesConfig:self.servicesConfig
                                                                    access:self.access];
    XCTAssert(session, @"Session creation failed");
    XCTAssertEqual(session.state, XISessionStateActive, @"Initial state is not correct");
    XCTAssert(session.services, @"Services creation failed");
    XCTAssertEqual(self.access, session.access, @"Invalid access setting");
}

- (void)testSessionInternalSuspend {
    
    [self.session suspend];
    
    XCTAssertTrue(self.notificationReceiver.suspendNotificationFired, @"Suspend not called back");
    
    self.notificationReceiver.suspendNotificationFired = NO;
    
    [self.session suspend];
    
    XCTAssertFalse(self.notificationReceiver.suspendNotificationFired, @"Suspend called back");
}

- (void)testSessionInternalResume {

    [self.session suspend];
    
    XCTAssertTrue(self.notificationReceiver.suspendNotificationFired, @"Suspend not called back");
    
    [self.session resume];
    
    XCTAssertTrue(self.notificationReceiver.resumeNotificationFired, @"Resume not called back");
    self.notificationReceiver.resumeNotificationFired = NO;
    
    [self.session resume];
    
    XCTAssertFalse(self.notificationReceiver.resumeNotificationFired, @"Resume called back");
}

- (void)testSessionInternalClose {
    [self.session close];
    XCTAssertEqual(self.session.state, XISessionStateInactive, @"Invalid state");
    XCTAssertTrue(self.notificationReceiver.closeNotificationFired, @"Close not called back");
    self.notificationReceiver.closeNotificationFired = NO;
    [self.session close];
    
    XCTAssertFalse(self.notificationReceiver.closeNotificationFired, @"Close called back");
}

- (void)testSessionInternalSuspendClosed {
    [self.session close];
    
    XCTAssertTrue(self.notificationReceiver.closeNotificationFired, @"Close not called back");
    self.notificationReceiver.suspendNotificationFired = NO;
    
    [self.session suspend];
    
    XCTAssertFalse(self.notificationReceiver.suspendNotificationFired, @"Suspend called back");
}

- (void)testSessionInternalResumeClosed {
    
    [self.session suspend];
    
    XCTAssertTrue(self.notificationReceiver.suspendNotificationFired, @"Suspend not called back");
    
    [self.session close];
    
    XCTAssertTrue(self.notificationReceiver.closeNotificationFired, @"Close not called back");
    
    [self.session resume];
    
    XCTAssertFalse(self.notificationReceiver.resumeNotificationFired, @"Resume called back");
}

- (void)testSessionProxyCreation {
    OCMockObject *mockSession = [OCMockObject mockForClass:[XISessionInternal class]];
    
    [[mockSession expect] setDelegateCaller:[OCMArg any]];
    XISessionProxy *session = [[XISessionProxy alloc] initWithInternal:(XISessionInternal *)mockSession];
    [mockSession verify];
    
    XCTAssert(session, @"Session creation failed");
}

- (void)testSessionProxyStaticCreation {
    OCMockObject *mockSession = [OCMockObject mockForClass:[XISessionInternal class]];
    [[mockSession expect] setDelegateCaller:[OCMArg any]];
    XISessionProxy *session = [XISessionProxy sessionWithInternal:(XISessionInternal *)mockSession];
    [mockSession verify];
    XCTAssert(session, @"Session creation failed");
}

- (void)testSessionImplProxying {
    OCMockObject *mockSession = [OCMockObject mockForClass:[XISessionInternal class]];

    [[mockSession expect] setDelegateCaller:[OCMArg any]];
    XISessionProxy *session = [XISessionProxy sessionWithInternal:(XISessionInternal *)mockSession];
    [mockSession verify];
    
    
    [(XISessionInternal *)[[mockSession expect] andReturnValue:OCMOCK_VALUE(XISessionStateInactive)] state];
    XISessionState returnedState = session.state;
    XCTAssertEqual(returnedState, XISessionStateInactive, "Invalid state proxy");
    [mockSession verify];
    
    [(XISessionInternal *)[[mockSession expect] andReturnValue:OCMOCK_VALUE(YES)] suspended];
    BOOL suspended = session.suspended;
    XCTAssertEqual(suspended, YES, "Invalid suspended proxy");
    [mockSession verify];
    
    XISessionServices *services = [[XISessionServices alloc] init];
    [[[mockSession expect] andReturn:services] services];
    XISessionServices *returnedServices = session.services;
    XCTAssertEqual(returnedServices, services, "Invalid services proxy");
    [mockSession verify];
    
    [[mockSession expect] close];
    [session close];
    [mockSession verify];
    
    [[mockSession expect] suspend];
    [session suspend];
    [mockSession verify];
    
    [[mockSession expect] resume];
    [session resume];
    [mockSession verify];
    
    [[mockSession expect] logout];
    [session logout];
    [mockSession verify];
}

@end

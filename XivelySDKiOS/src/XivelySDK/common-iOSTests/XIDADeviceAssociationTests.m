//
//  XIDADeviceAssociation.m
//  common-iOS
//
//  Created by vfabian on 17/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "XIDADeviceAssociation.h"
#import "XISessionInternal.h"
#import "XISessionServicesInternal.h"
#import <XivelySDK/DeviceAssociation/XISessionServices+DeviceAssociation.h>
#import <XivelySDK/DeviceAssociation/XIDeviceAssociation.h>
#import "XIDeviceAssociationProxy.h"
#import "XIAccess.h"
#import <Internals/Session/XICOSessionNotifications.h>


@interface XIDADeviceAssociationTests : XCTestCase

@property (strong, nonatomic) XCTestExpectation* expectation;
@property(nonatomic, strong)XIDADeviceAssociation *deviceAssociation;
@property(nonatomic, strong)XIAccess *access;
@property(nonatomic, strong)OCMockObject *mockCallProvider;
@property(nonatomic, strong)OCMockObject *mockProxy;
@property(nonatomic, strong)OCMockObject *mockDelegate;
@property(nonatomic, strong)OCMockObject *mockDeviceAssociationCall;
@property(nonatomic, strong)NSString *associationCode;
@property(nonatomic, strong)XICOSessionNotifications *notifications;

@end

@implementation XIDADeviceAssociationTests

- (void)setUp {
    [super setUp];
    
    self.access = [XIAccess new];
    self.access.accountId = @"sdkgjsdhgklshgkdgdsfkgjh";
    self.access.mqttPassword = @"sdkghjgfjhgfhgfjsdhgklshgkdgdsfkgjh";
    self.access.mqttDeviceId = @"sdkghjgfhjgfhgfghjfhgfjsdhgklshgkdgdsfkgjh";
    self.access.jwt = @"sdkljghsdalkgjhgrkl4jh35k435jh34kl5j324h5lk345jh";
    
    self.associationCode = @"wkrjth54lk5j3h5lk43h43l2k6h35lkjth43kl4jh6543klh543klh5kljh";
    
    self.mockCallProvider = [OCMockObject mockForProtocol:@protocol(XIDADeviceAssociationCallProvider)];
    self.mockProxy = [OCMockObject mockForProtocol:@protocol(XIDeviceAssociation)];
    self.mockDelegate = [OCMockObject mockForProtocol:@protocol(XIDeviceAssociationDelegate)];
    self.mockDeviceAssociationCall = [OCMockObject mockForProtocol:@protocol(XIDADeviceAssociationCall)];
    self.notifications = [XICOSessionNotifications new];
    self.deviceAssociation = [[XIDADeviceAssociation alloc] initWithLogger:nil
                                                              callProvider:(id<XIDADeviceAssociationCallProvider>)self.mockCallProvider
                                                                     proxy:(id<XIDeviceAssociation>)self.mockProxy
                                                                    access:self.access
                                                             notifications:self.notifications
                                                                    config:nil];
    self.deviceAssociation.delegate = (id<XIDeviceAssociationDelegate>)self.mockDelegate;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIDADeviceAssociationCreationViaSessionServices {
    OCMockObject *session = [OCMockObject mockForClass:[XISessionInternal class]];
    XISessionServicesInternal *services = [[XISessionServicesInternal alloc] initWithSession:(XISessionInternal *)session];
    [[[session stub] andReturnValue:OCMOCK_VALUE(NO)] suspended];
    [[[session stub] andReturn:nil] log];
    [[[session stub] andReturn:self.mockCallProvider] restCallProvider];
    XISdkConfig *sdkConfig = [[XISdkConfig alloc] init];
    XIServicesConfig *servicesConfig = [[XIServicesConfig alloc] initWithSdkConfig: sdkConfig];
    [[[session stub] andReturn:servicesConfig] servicesConfig];
    [[[session stub] andReturn:self.access] access];
    [[[session stub] andReturn:self.notifications] notifications];
    
    id<XIDeviceAssociation> association = [services deviceAssociation];
    XCTAssert(association, @"Association creation failed");
}

- (void)testXIDADeviceAssociationCreation {
    XCTAssert(self.deviceAssociation, @"Device Association instance creation failed");
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateIdle, @"Invalid initial state");
    XCTAssertEqual(self.deviceAssociation.delegate, self.mockDelegate, @"Invalid delegate setting");
}

- (void)testXIDADeviceAssociationIdleCancel {
    [self.deviceAssociation cancel];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid state");
}

- (void)testXIDADeviceAssociationIdleStart {
    [[[self.mockCallProvider expect] andReturn:self.mockDeviceAssociationCall] deviceAssociationCall];
    [[self.mockDeviceAssociationCall expect] setDelegate:(id<NSFileManagerDelegate>)self.deviceAssociation];
    [[self.mockDeviceAssociationCall expect] requestWithEndUserId:self.access.blueprintUserId associationCode:self.associationCode];
    
    [self.deviceAssociation associateDeviceWithAssociationCode:self.associationCode];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateAssociating, @"Invalid state");
    [self.mockCallProvider verify];
    [self.mockDeviceAssociationCall verify];
}

- (void)testXIDADeviceAssociationAssociatingCancel {
    OCMockObject *mockDeviceAssociationCode = [OCMockObject mockForProtocol:@protocol(XIDADeviceAssociationCall)];
    [[[self.mockCallProvider expect] andReturn:mockDeviceAssociationCode] deviceAssociationCall];
    [[mockDeviceAssociationCode expect] setDelegate:(id<NSFileManagerDelegate>)self.deviceAssociation];
    [[mockDeviceAssociationCode expect] requestWithEndUserId:self.access.blueprintUserId associationCode:self.associationCode];
    
    [self.deviceAssociation associateDeviceWithAssociationCode:self.associationCode];
    [self.mockCallProvider verify];
    [mockDeviceAssociationCode verify];
    
    [[mockDeviceAssociationCode expect] cancel];
    [self.deviceAssociation cancel];
    [mockDeviceAssociationCode verify];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid state");
}

- (void)testXIDADeviceAssociationPositiveCallback {
    [self testXIDADeviceAssociationIdleStart];
    NSString *deviceId = @"lkvfdhklgshbdlkjbghfdkljh";
    
    
    [[self.mockDelegate expect] deviceAssociation:(id<XIDeviceAssociation>)self.mockProxy didSucceedWithDeviceId:deviceId];
    [((id<XIDADeviceAssociationCallDelegate>)self.deviceAssociation) deviceAssociationCall:nil didSucceedWithDeviceId:deviceId];
    
    self.expectation = [self expectationWithDescription:@""];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateEnded, @"Invalid end state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIDADeviceAssociationErrorCallback {
    [self testXIDADeviceAssociationIdleStart];
    NSError *error = [NSError errorWithDomain:@"" code:99 userInfo:nil];
    
    
    [[self.mockDelegate expect] deviceAssociation:(id<XIDeviceAssociation>)self.mockProxy didFailWithError:error];
    [((id<XIDADeviceAssociationCallDelegate>)self.deviceAssociation) deviceAssociationCall:nil didFailWithError:error];
    
    self.expectation = [self expectationWithDescription:@""];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateError, @"Invalid end state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIDADeviceAssociationCancelJustBeforePositiveCallback {
    [self testXIDADeviceAssociationIdleStart];
    NSString *deviceId = @"lkvfdhklgshbdlkjbghfdkljh";
    
    
    [[self.mockDelegate reject] deviceAssociation:(id<XIDeviceAssociation>)self.mockProxy didSucceedWithDeviceId:deviceId];
    [((id<XIDADeviceAssociationCallDelegate>)self.deviceAssociation) deviceAssociationCall:nil didSucceedWithDeviceId:deviceId];
    
    [self.deviceAssociation cancel];
    
    self.expectation = [self expectationWithDescription:@""];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid end state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIDADeviceAssociationCancelJustBeforeErrorCallback {
    [self testXIDADeviceAssociationIdleStart];
    NSError *error = [NSError errorWithDomain:@"" code:99 userInfo:nil];
    
    [[self.mockDelegate reject] deviceAssociation:(id<XIDeviceAssociation>)self.mockProxy didFailWithError:error];
    [((id<XIDADeviceAssociationCallDelegate>)self.deviceAssociation) deviceAssociationCall:nil didFailWithError:error];
    
    self.expectation = [self expectationWithDescription:@""];
    
    [self.deviceAssociation cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid end state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}


- (void)testXIDADeviceAssociationIdleSuspend {
    [self propagateSuspend];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateIdle, @"Invalid state");
}

- (void)testXIDADeviceAssociationSuspendedIdleAssociate {
    [self testXIDADeviceAssociationIdleSuspend];
    [self.deviceAssociation associateDeviceWithAssociationCode:self.associationCode];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateAssociating, @"Invalid state");
}

- (void)testXIDADeviceAssociationSuspendedIdleCancel {
    [self testXIDADeviceAssociationIdleSuspend];
    [self.deviceAssociation cancel];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid state");
}

- (void)testXIDADeviceAssociationSuspendedIdleResume {
    [self testXIDADeviceAssociationIdleSuspend];
    [self propagateResume];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateIdle, @"Invalid state");
}

- (void)testXIDADeviceAssociationAssociatingSuspend {
    [self testXIDADeviceAssociationIdleStart];
    [[self.mockDeviceAssociationCall expect] cancel];
    [self propagateSuspend];
    [self.mockDeviceAssociationCall verify];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateAssociating, @"Invalid state");
}

- (void)testXIDADeviceAssociationSuspendedCancel {
    [self testXIDADeviceAssociationAssociatingSuspend];
    [[self.mockDeviceAssociationCall reject] cancel];
    [self.deviceAssociation cancel];
    [self.mockDeviceAssociationCall verify];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid state");
}

- (void)testXIDADeviceAssociationSuspendedResume {
    [self testXIDADeviceAssociationAssociatingSuspend];
    
    [[[self.mockCallProvider expect] andReturn:self.mockDeviceAssociationCall] deviceAssociationCall];
    [[self.mockDeviceAssociationCall expect] setDelegate:(id<NSFileManagerDelegate>)self.deviceAssociation];
    [[self.mockDeviceAssociationCall expect] requestWithEndUserId:self.access.blueprintUserId associationCode:self.associationCode];
    [self propagateResume];
    [self.mockCallProvider verify];
    [self.mockDeviceAssociationCall verify];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateAssociating, @"Invalid state");
}

- (void)testXIDADeviceAssociationParentSessionFinishedWhileNotRunning {
    [self testXIDADeviceAssociationAssociatingSuspend];
    [self propagateClose];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid state");
}

- (void)testXIDADeviceAssociationParentSessionFinishedWhileRunning {
    [self testXIDADeviceAssociationIdleStart];
    
    [[self.mockDeviceAssociationCall expect] cancel];
    [self propagateClose];
    [self.mockDeviceAssociationCall verify];
    
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid state");
}

- (void)testXIDADeviceAssociationParentSessionCleanUpWhileNotRunning {
    [self testXIDADeviceAssociationAssociatingSuspend];
    [self propagateClose];
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid state");
}

- (void)testXIDADeviceAssociationParentSessionCleanUpWhileRunning {
    [self testXIDADeviceAssociationIdleStart];
    
    [[self.mockDeviceAssociationCall expect] cancel];
    [self propagateClose];
    [self.mockDeviceAssociationCall verify];
    
    XCTAssertEqual(self.deviceAssociation.state, XIDeviceAssociationStateCanceled, @"Invalid state");
}

//XIDADeviceAssociationProxy
- (void)testXIDADeviceAssociationProxyCreation {
    XIDeviceAssociationProxy *proxy = [[XIDeviceAssociationProxy alloc] initWithInternal:self.deviceAssociation];
    XCTAssert(proxy, @"Instance creation failed");
}

- (void)testXIDADeviceAssociationProxyProxing {
    OCMockObject *mockDeviceAssociation = [OCMockObject mockForProtocol:@protocol(XIDeviceAssociation)];
    XIDeviceAssociationProxy *proxy = [[XIDeviceAssociationProxy alloc] initWithInternal:(id<XIDeviceAssociation>)mockDeviceAssociation];
    
    [(id<XIDeviceAssociation>)[[mockDeviceAssociation expect] andReturnValue:OCMOCK_VALUE(XIDeviceAssociationStateAssociating)] state];
    XCTAssertEqual(proxy.state, XIDeviceAssociationStateAssociating, @"Invalid state retrival");
    [mockDeviceAssociation verify];
    
    [[[mockDeviceAssociation expect] andReturn:self.mockDelegate] delegate];
    XCTAssertEqual(proxy.delegate, self.mockDelegate, @"Invalid state retreival");
    [mockDeviceAssociation verify];
    
    [[mockDeviceAssociation expect] setDelegate:(id<NSFileManagerDelegate>)self.mockDelegate];
    proxy.delegate = (id<XIDeviceAssociationDelegate>)self.mockDelegate;
    [mockDeviceAssociation verify];
    
    NSError *error = [NSError errorWithDomain:@"dsgs" code:567 userInfo:nil];
    [[[mockDeviceAssociation expect] andReturn:error] error];
    XCTAssertEqual(error, proxy.error, @"Invalid error retreival");
    [mockDeviceAssociation verify];
    
    [[mockDeviceAssociation expect] associateDeviceWithAssociationCode:self.associationCode];
    [proxy associateDeviceWithAssociationCode:self.associationCode];
    [mockDeviceAssociation verify];
    
    [[mockDeviceAssociation expect] cancel];
    [proxy cancel];
    [mockDeviceAssociation verify];
}

- (void)propagateSuspend {
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidSuspendNotification object:nil];
}

- (void)propagateResume {
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidResumeNotification object:nil];
}

- (void)propagateClose {
    [self.notifications.sessionNotificationCenter postNotificationName:XISessionDidCloseNotification object:nil];
}

@end

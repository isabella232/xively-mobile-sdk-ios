//
//  XIDEviceInfoListTests.m
//  common-iOS
//
//  Created by vfabian on 25/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XISessionInternal.h"
#import "XIDeviceInfoListProxy.h"
#import "XIDIDeviceInfoList.h"
#import "XISessionServicesInternal.h"
#import "XISessionServices+DeviceInfo.h"
#import "XIDIDeviceInfoList.h"

@interface XIDeviceInfoListTests : XCTestCase

@property(nonatomic, strong)XIAccess *access;
@property(nonatomic, strong)OCMockObject *mockCallProvider;
@property(nonatomic, strong)OCMockObject *mockProxy;
@property(nonatomic, strong)OCMockObject *mockDelegate;
@property(nonatomic, strong)OCMockObject *mockDeviceInfoListCall;
@property(nonatomic, strong)OCMockObject *mockDeviceInfoListCall2;
@property(nonatomic, strong)OCMockObject *mockDeviceInfoListCall3;
@property(nonatomic, strong)XICOSessionNotifications *notifications;
@property(nonatomic, strong)OCMockObject *mockServicesConfig;
@property(nonatomic, strong)XIDIDeviceInfoList *deviceInfoList;
@property(nonatomic, strong)XCTestExpectation *expectation;

@end

static NSUInteger const kListPageSize = 10;
static NSUInteger const kAggregateMaxSize = 5;

@implementation XIDeviceInfoListTests

- (void)setUp {
    [super setUp];
    self.access = [XIAccess new];
    self.access.accountId = @"sdkgjsdhgklshgkdgdsfkgjh";
    self.access.mqttPassword = @"sdkghjgfjhgfhgfjsdhgklshgkdgdsfkgjh";
    self.access.mqttDeviceId = @"sdkghjgfhjgfhgfghjfhgfjsdhgklshgkdgdsfkgjh";
    self.access.jwt = @"sdkljghsdalkgjhgrkl4jh35k435jh34kl5j324h5lk345jh";
    
    self.mockCallProvider = [OCMockObject mockForProtocol:@protocol(XIDIDeviceInfoListCallProvider)];
    self.mockProxy = [OCMockObject mockForProtocol:@protocol(XIDeviceInfoList)];
    self.mockDelegate = [OCMockObject mockForProtocol:@protocol(XIDeviceInfoListDelegate)];
    self.mockDeviceInfoListCall = [OCMockObject mockForProtocol:@protocol(XIDIDeviceInfoListCall)];
    self.mockDeviceInfoListCall2 = [OCMockObject mockForProtocol:@protocol(XIDIDeviceInfoListCall)];
    self.mockDeviceInfoListCall3 = [OCMockObject mockForProtocol:@protocol(XIDIDeviceInfoListCall)];
    self.notifications = [XICOSessionNotifications new];
    self.mockServicesConfig = [OCMockObject mockForClass:[XIServicesConfig class]];
    
    [[[self.mockServicesConfig stub] andReturnValue:OCMOCK_VALUE((NSUInteger)kListPageSize)] blueprintListingMaxPageSize];
    [[[self.mockServicesConfig stub] andReturnValue:OCMOCK_VALUE((NSUInteger)kAggregateMaxSize)] blueprintAggregateMaxCallCount];
    
    self.deviceInfoList = [[XIDIDeviceInfoList alloc] initWithLogger:nil
                                                        callProvider:(id<XIDIDeviceInfoListCallProvider>)self.mockCallProvider
                                                               proxy:(id<XIDeviceInfoList>)self.mockProxy
                                                              access:self.access
                                                       notifications:self.notifications
                                                              config:(XIServicesConfig *)self.mockServicesConfig];
    self.deviceInfoList.delegate = (id<XIDeviceInfoListDelegate>)self.mockDelegate;
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateIdle);
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIDeviceInfoListProxyCreation {
    OCMockObject *mockInternal = [OCMockObject mockForProtocol:@protocol(XIDeviceInfoList)];
    XIDeviceInfoListProxy *proxy = [[XIDeviceInfoListProxy alloc] initWithInternal:(id<XIDeviceInfoList>)mockInternal];
    XCTAssert(proxy, @"Proxy creation failed");
}

- (void)testXIDeviceInfoListProxyProxying {
    OCMockObject *mockInternal = [OCMockObject mockForProtocol:@protocol(XIDeviceInfoList)];
    XIDeviceInfoListProxy *proxy = [[XIDeviceInfoListProxy alloc] initWithInternal:(id<XIDeviceInfoList>)mockInternal];
    
    [(id<XIDeviceInfoList>)[[mockInternal expect] andReturnValue:OCMOCK_VALUE(XIDeviceInfoListStateRunning)] state];
    XCTAssertEqual(XIDeviceInfoListStateRunning, proxy.state, @"Invalid state");
    [mockInternal verify];
    
    NSObject *obj = [NSObject new];
    [(id<XIDeviceInfoList>)[[mockInternal expect] andReturn:obj] delegate];
    XCTAssertEqual(obj, proxy.delegate, @"Invalid delegate getting");
    [mockInternal verify];
    
    [(id<XIDeviceInfoList>)[mockInternal expect] setDelegate:(id<XIDeviceInfoListDelegate>)obj];
    proxy.delegate = (id<XIDeviceInfoListDelegate>)obj;
    [mockInternal verify];
    
    NSError *error = [NSError errorWithDomain:@"sgs" code:5 userInfo:nil];
    [(id<XIDeviceInfoList>)[[mockInternal expect] andReturn:error] error];
    XCTAssertEqual(error, proxy.error, @"Invalid error getting");
    [mockInternal verify];
    
    [(id<XIDeviceInfoList>)[mockInternal expect] requestList];
    [proxy requestList];
    [mockInternal verify];
    
    [(id<XIDeviceInfoList>)[mockInternal expect] cancel];
    [proxy cancel];
    [mockInternal verify];
}

- (void)testXIDeviceInfoListCreationThroughSessionServices {
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
    
    id<XIDeviceInfoList> association = [services deviceInfoList];
    XCTAssert(association, @"Association creation failed");
}

- (void)testXIDeviceInfoListCreation {
    XCTAssert(self.deviceInfoList, @"Creation failed");
}

- (void)testXIDeviceInfoListRequestList {
    XCTAssert(self.deviceInfoList, @"Creation failed");
    
    [[[self.mockCallProvider expect] andReturn:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall] deviceInfoListCall];
    [[self.mockDeviceInfoListCall expect] setDelegate:[OCMArg any]];
    [[self.mockDeviceInfoListCall expect]requestWithAccountId:self.access.accountId
                                               organizationId:nil
                                                     pageSize:kListPageSize
                                                         page:1 ];
    [self.deviceInfoList requestList];
    [self.mockCallProvider verify];
    [self.mockDeviceInfoListCall verify];
    
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateRunning, @"Invalid state");
}

- (void)testXIDeviceInfoListIdleCancel {
    [self.deviceInfoList cancel];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
}

- (void)testXIDeviceInfoListIdleSuspendResume {
    [self propagateSuspend];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateIdle, @"Invalid state");
    [self propagateResume];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateIdle, @"Invalid state");
}

- (void)testXIDeviceInfoListIdleSuspendCancelResume {
    [self propagateSuspend];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateIdle, @"Invalid state");
    [self.deviceInfoList cancel];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
    [self propagateResume];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
}

- (void)testXIDeviceInfoListIdleSuspendRequestListResume {
    [self propagateSuspend];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateIdle, @"Invalid state");
    [self.deviceInfoList requestList];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateRunning, @"Invalid state");
    
    [[[self.mockCallProvider expect] andReturn:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall] deviceInfoListCall];
    [[[self.mockServicesConfig expect] andReturnValue:OCMOCK_VALUE((NSUInteger)kListPageSize)] blueprintListingMaxPageSize];
    [[self.mockDeviceInfoListCall expect] setDelegate:[OCMArg any]];
    [[self.mockDeviceInfoListCall expect]requestWithAccountId:self.access.accountId
                                               organizationId:self.access.blueprintOrganizationId
                                                     pageSize:kListPageSize
                                                         page:1 ];
    [self propagateResume];
    [self.mockCallProvider verify];
    [self.mockDeviceInfoListCall verify];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateRunning, @"Invalid state");
}

- (void)testXIDeviceInfoListIdleSuspendRequestListCancelResume {
    [self propagateSuspend];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateIdle, @"Invalid state");
    [self.deviceInfoList requestList];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateRunning, @"Invalid state");
    [self.deviceInfoList cancel];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
    [self propagateResume];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
}

- (void)testXIDeviceInfoListIdleSessionClosed {
    [self propagateClose];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
}

- (void)testXIDeviceInfoListSuspendedIdleSessionClosed {
    [self propagateSuspend];
    [self propagateClose];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
}

- (void)testXIDeviceInfoListSuspendedRunningSessionClosed {
    [self propagateSuspend];
    [self.deviceInfoList requestList];
    [self propagateClose];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
}


- (void)testXIDeviceInfoListRunningInitialCallCancel {
    [self testXIDeviceInfoListRequestList];
    
    [[self.mockDeviceInfoListCall expect] setDelegate:nil];
    [[self.mockDeviceInfoListCall expect] cancel];
    [self.deviceInfoList cancel];
    [self.mockDeviceInfoListCall verify];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
}

- (void)testXIDeviceInfoListRunningInitialCallError {
    [self testXIDeviceInfoListRequestList];
    
    NSError *error = [NSError errorWithDomain:@"sfgsdf" code:67 userInfo:nil];
    
    [(id<XIDeviceInfoListDelegate>)[self.mockDelegate expect] deviceInfoList:(id<XIDeviceInfoList>)self.mockProxy didFailWithError:error];
    [[self.mockDeviceInfoListCall expect] setDelegate:nil];
    [[self.mockDeviceInfoListCall expect] cancel];
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall didFailWithError:error];
    [self.mockDeviceInfoListCall verify];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.deviceInfoList.error, error, @"Invalid error");
        XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateError, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIDeviceInfoListRunningInitialCallErrorWhileCanceled {
    [self testXIDeviceInfoListRequestList];
    
    NSError *error = [NSError errorWithDomain:@"sfgsdf" code:67 userInfo:nil];
    
    [(id<XIDeviceInfoListDelegate>)[self.mockDelegate reject] deviceInfoList:[OCMArg any] didFailWithError:[OCMArg any]];
    [[self.mockDeviceInfoListCall expect] setDelegate:nil];
    [[self.mockDeviceInfoListCall expect] cancel];
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall didFailWithError:error];
    [self.mockDeviceInfoListCall verify];
    
    [self.deviceInfoList cancel];
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertNil(self.deviceInfoList.error, @"Invalid error");
        XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIDeviceInfoListRunningInitialReturnedAllElements {
    [self testXIDeviceInfoListRequestList];
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    
    XIDIDeviceInfoListMeta *meta = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:@{@"count" : @(3), @"page": @(1), @"pageSize" : @(10)}];
    
    [(id<XIDeviceInfoListDelegate>)[self.mockDelegate expect] deviceInfoList:(id<XIDeviceInfoList>)self.mockProxy didReceiveList:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSArray *a = (NSArray *)obj;
        return a.count == 3 && [a containsObject:result1] && [a containsObject:result2] && [a containsObject:result3];
    }]];
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall
               didSucceedWithDeviceInfoList:@[result1, result2, result3]
                                       meta:meta];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateEnded, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIDeviceInfoListRunningInitialReturnedAllElementsWhileCanceled {
    [self testXIDeviceInfoListRequestList];
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    
    XIDIDeviceInfoListMeta *meta = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:@{@"count" : @(3), @"page": @(1), @"pageSize" : @(10)}];
    
    [(id<XIDeviceInfoListDelegate>)[self.mockDelegate reject] deviceInfoList:[OCMArg any] didReceiveList:[OCMArg any]];
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall
               didSucceedWithDeviceInfoList:@[result1, result2, result3]
                                       meta:meta];
    
    [self.deviceInfoList cancel];
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIDeviceInfoListRunningInitialReturnedNotAllOthersReturnInOneAggregate {
    [self testXIDeviceInfoListRequestList];
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    
    XIDIDeviceInfoListMeta *meta = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:@{@"count" : @(34), @"page": @(1), @"pageSize" : @(10)}];
    
    [[[self.mockCallProvider expect] andReturn:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall2] deviceInfoListCall];
    [[self.mockDeviceInfoListCall2 expect] setDelegate:[OCMArg any]];
    [[self.mockDeviceInfoListCall2 expect]requestWithAccountId:self.access.accountId
                                               organizationId:self.access.blueprintOrganizationId
                                                     pageSize:10
                                                    pagesFrom:2
                                                      pagesTo:4 ];
    
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall
               didSucceedWithDeviceInfoList:@[result1, result2, result3]
                                       meta:meta];
    
    [self.mockCallProvider verify];
    [self.mockDeviceInfoListCall verify];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateRunning, @"Invalid state");
}

- (void)testXIDeviceInfoListRunningInitialReturnedNotAllOthersReturnInOneAggregateWithExactPageSizeCount {
    [self testXIDeviceInfoListRequestList];
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    
    XIDIDeviceInfoListMeta *meta = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:@{@"count" : @(30), @"page": @(1), @"pageSize" : @(10)}];
    
    [[[self.mockCallProvider expect] andReturn:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall2] deviceInfoListCall];
    [[self.mockDeviceInfoListCall2 expect] setDelegate:[OCMArg any]];
    [[self.mockDeviceInfoListCall2 expect]requestWithAccountId:self.access.accountId
                                                organizationId:self.access.blueprintOrganizationId
                                                      pageSize:10
                                                     pagesFrom:2
                                                       pagesTo:3 ];
    
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall
               didSucceedWithDeviceInfoList:@[result1, result2, result3]
                                       meta:meta];
    
    [self.mockCallProvider verify];
    [self.mockDeviceInfoListCall verify];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateRunning, @"Invalid state");
}

- (void)testXIDeviceInfoListRunningInitialReturnedNotAllOthersReturnInMoreAggregate {
    [self testXIDeviceInfoListRequestList];
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    
    XIDIDeviceInfoListMeta *meta = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:@{@"count" : @(74), @"page": @(1), @"pageSize" : @(10)}];
    
    [[[self.mockCallProvider expect] andReturn:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall2] deviceInfoListCall];
    [[[self.mockCallProvider expect] andReturn:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall3] deviceInfoListCall];
    [[self.mockDeviceInfoListCall2 expect] setDelegate:[OCMArg any]];
    [[self.mockDeviceInfoListCall2 expect]requestWithAccountId:self.access.accountId
                                                organizationId:self.access.blueprintOrganizationId
                                                      pageSize:10
                                                     pagesFrom:2
                                                       pagesTo:6 ];
    
    [[self.mockDeviceInfoListCall3 expect] setDelegate:[OCMArg any]];
    [[self.mockDeviceInfoListCall3 expect]requestWithAccountId:self.access.accountId
                                                organizationId:self.access.blueprintOrganizationId
                                                      pageSize:10
                                                     pagesFrom:7
                                                       pagesTo:8 ];
    
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall
               didSucceedWithDeviceInfoList:@[result1, result2, result3]
                                       meta:meta];
    
    [self.mockCallProvider verify];
    [self.mockDeviceInfoListCall verify];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateRunning, @"Invalid state");
}

- (void)testXIDeviceInfoListCancelWhileMoreAggregateIsRunning {
    [self testXIDeviceInfoListRunningInitialReturnedNotAllOthersReturnInMoreAggregate];
    
    [[self.mockDeviceInfoListCall2 expect] setDelegate:nil];
    [[self.mockDeviceInfoListCall2 expect] cancel];
    [[self.mockDeviceInfoListCall3 expect] setDelegate:nil];
    [[self.mockDeviceInfoListCall3 expect] cancel];
    [self.deviceInfoList cancel];
    [self.mockDeviceInfoListCall2 verify];
    [self.mockDeviceInfoListCall3 verify];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
}

- (void)testXIDeviceInfoListSuspendAndResumeWhileMoreAggregateIsRunning {
    [self testXIDeviceInfoListRunningInitialReturnedNotAllOthersReturnInMoreAggregate];
    
    [[self.mockDeviceInfoListCall2 expect] setDelegate:nil];
    [[self.mockDeviceInfoListCall2 expect] cancel];
    [[self.mockDeviceInfoListCall3 expect] setDelegate:nil];
    [[self.mockDeviceInfoListCall3 expect] cancel];
    [self propagateSuspend];
    [self.mockDeviceInfoListCall2 verify];
    [self.mockDeviceInfoListCall3 verify];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateRunning, @"Invalid state");
    
    [[[self.mockCallProvider expect] andReturn:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall] deviceInfoListCall];
    [[[self.mockServicesConfig expect] andReturnValue:OCMOCK_VALUE((NSUInteger)kListPageSize)] blueprintListingMaxPageSize];
    [[self.mockDeviceInfoListCall expect] setDelegate:[OCMArg any]];
    [[self.mockDeviceInfoListCall expect]requestWithAccountId:self.access.accountId
                                               organizationId:self.access.blueprintOrganizationId
                                                     pageSize:kListPageSize
                                                         page:1 ];
    [self propagateResume];
    [self.mockCallProvider verify];
    [self.mockDeviceInfoListCall verify];
    XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateRunning, @"Invalid state");
}

- (void)testXIDeviceInfoListReceiveAggregateResults {
    [self testXIDeviceInfoListRunningInitialReturnedNotAllOthersReturnInMoreAggregate];
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    
    XIDIDeviceInfoListMeta *meta2 = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:@{@"count" : @(74), @"page": @(2), @"pageSize" : @(10)}];
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall2
               didSucceedWithDeviceInfoList:@[result1]
                                       meta:meta2];
    
    XIDIDeviceInfoListMeta *meta3 = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:@{@"count" : @(74), @"page": @(3), @"pageSize" : @(10)}];
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall3
               didSucceedWithDeviceInfoList:@[result2, result3]
                                       meta:meta3];
    
    [(id<XIDeviceInfoListDelegate>)[self.mockDelegate expect] deviceInfoList:(id<XIDeviceInfoList>)self.mockProxy didReceiveList:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSArray *a = (NSArray *)obj;
        return a.count == 6 && [a containsObject:result1] && [a containsObject:result2] && [a containsObject:result3];
    }]];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateEnded, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXIDeviceInfoListReceiveAggregateResultsWhileCanceled {
    [self testXIDeviceInfoListRunningInitialReturnedNotAllOthersReturnInMoreAggregate];
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    
    XIDIDeviceInfoListMeta *meta2 = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:@{@"count" : @(74), @"page": @(2), @"pageSize" : @(10)}];
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall2
               didSucceedWithDeviceInfoList:@[result1]
                                       meta:meta2];
    
    XIDIDeviceInfoListMeta *meta3 = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:@{@"count" : @(74), @"page": @(3), @"pageSize" : @(10)}];
    [self.deviceInfoList deviceInfoListCall:(id<XIDIDeviceInfoListCall>)self.mockDeviceInfoListCall3
               didSucceedWithDeviceInfoList:@[result2, result3]
                                       meta:meta3];
    
    [(id<XIDeviceInfoListDelegate>)[self.mockDelegate reject] deviceInfoList:[OCMArg any] didReceiveList:[OCMArg any]];
    
    [self.deviceInfoList cancel];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.deviceInfoList.state, XIDeviceInfoListStateCanceled, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
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

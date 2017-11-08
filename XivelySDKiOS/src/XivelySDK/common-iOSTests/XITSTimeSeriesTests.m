//
//  XITSTimeSeriesTests.m
//  common-iOS
//
//  Created by vfabian on 15/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIAccess.h"

#import "XITSTimeSeries.h"
#import "XITimeSeriesProxy.h"
#import "NSDateFormatter+XITimeSeries.h"

#import "XISessionServicesInternal.h"
#import "XISessionServices+TimeSeries.h"



@interface XITSTimeSeriesTests : XCTestCase

@property(nonatomic, strong)XIAccess *access;
@property(nonatomic, strong)OCMockObject *mockCallProvider;
@property(nonatomic, strong)OCMockObject *mockProxy;
@property(nonatomic, strong)OCMockObject *mockDelegate;
@property(nonatomic, strong)OCMockObject *mockTimeSeriesCall;
@property(nonatomic, strong)XICOSessionNotifications *notifications;
@property(nonatomic, strong)OCMockObject *mockServicesConfig;
@property(nonatomic, strong)XITSTimeSeries *timeSeries;
@property(nonatomic, strong)XCTestExpectation *expectation;

@property(nonatomic, strong)NSDateFormatter *dateFormatter;
@property(nonatomic, strong)NSString *channel;
@property(nonatomic, strong)NSString *startDateString;
@property(nonatomic, strong)NSString *endDateString;
@property(nonatomic, strong)NSDate *startDate;
@property(nonatomic, strong)NSDate *endDate;


@end

static NSUInteger const kTimeSeriesPageSize = 10;


@implementation XITSTimeSeriesTests

- (void)setUp {
    [super setUp];
    self.access = [XIAccess new];
    self.access.accountId = @"sdkgjsdhgklshgkdgdsfkgjh";
    self.access.mqttPassword = @"sdkghjgfjhgfhgfjsdhgklshgkdgdsfkgjh";
    self.access.mqttDeviceId = @"sdkghjgfhjgfhgfghjfhgfjsdhgklshgkdgdsfkgjh";
    self.access.jwt = @"sdkljghsdalkgjhgrkl4jh35k435jh34kl5j324h5lk345jh";
    
    self.dateFormatter = [NSDateFormatter timeSeriesDateFormatter];
    
    self.channel = @"43k3kl4jh43klh3kj6h33l4kj25h4lkj5hl5kj/asdgs/gfds/gdfg/fd/gdfs/gdfs/gdfs/gd/sg";
    self.startDateString = @"2015-09-14T11:30:02Z";
    self.endDateString = @"2015-09-14T22:30:02Z";
    self.startDate = [self.dateFormatter dateFromString:self.startDateString];
    self.endDate = [self.dateFormatter dateFromString:self.endDateString];
    
    self.mockCallProvider = [OCMockObject mockForProtocol:@protocol(XITSTimeSeriesCallProvider)];
    self.mockProxy = [OCMockObject mockForProtocol:@protocol(XITimeSeries)];
    self.mockDelegate = [OCMockObject mockForProtocol:@protocol(XITimeSeriesDelegate)];
    self.mockTimeSeriesCall = [OCMockObject mockForProtocol:@protocol(XITSTimeSeriesCall)];
    self.notifications = [XICOSessionNotifications new];
    self.mockServicesConfig = [OCMockObject mockForClass:[XIServicesConfig class]];
    
    [[[self.mockServicesConfig stub] andReturnValue:OCMOCK_VALUE((NSUInteger)kTimeSeriesPageSize)] timeseriesPageSize];
    
    self.timeSeries = [[XITSTimeSeries alloc] initWithLogger:nil
                                                        callProvider:(id<XITSTimeSeriesCallProvider>)self.mockCallProvider
                                                               proxy:(id<XITimeSeries>)self.mockProxy
                                                              access:self.access
                                                       notifications:self.notifications
                                                              config:(XIServicesConfig *)self.mockServicesConfig];
    self.timeSeries.delegate = (id<XITimeSeriesDelegate>)self.mockDelegate;
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateIdle);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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
    
    id<XITimeSeries> timeSeries = [services timeSeries];
    XCTAssert(timeSeries, @"Time series creation failed");
}


- (void)testXITSTimeSeriesCreation {
    XCTAssert(self.timeSeries, @"Creation failed");
}


- (void)testXITSTimeSeriesRequest {
    
    [[[self.mockCallProvider expect] andReturn:(id<XITSTimeSeriesCallProvider>)self.mockTimeSeriesCall] timeSeriesCall];
    [[self.mockTimeSeriesCall expect] setDelegate:[OCMArg any]];
    [[self.mockTimeSeriesCall expect] requestWithTopic:self.channel
                                             startDate:self.startDate
                                               endDate:self.endDate
                                              pageSize:kTimeSeriesPageSize
                                           pagingToken:nil];

    [self.timeSeries requestTimeSeriesItemsForChannel:self.channel startDate:self.startDate endDate:self.endDate];
    [self.mockCallProvider verify];
    [self.mockTimeSeriesCall verify];
 
 XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateRunning, @"Invalid state");
 }

- (void)testXITSTimeSeriesIdleCancel {
    [self.timeSeries cancel];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
}
 
- (void)testXITSTimeSeriesIdleSuspendResume {
    [self propagateSuspend];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateIdle, @"Invalid state");
    [self propagateResume];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateIdle, @"Invalid state");
}
 
- (void)testXITSTimeSeriesIdleSuspendCancelResume {
    [self propagateSuspend];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateIdle, @"Invalid state");
    [self.timeSeries cancel];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
    [self propagateResume];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
}

- (void)testXITSTimeSeriesIdleSuspendRequestResume {
    [self propagateSuspend];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateIdle, @"Invalid state");
    [self.timeSeries requestTimeSeriesItemsForChannel:self.channel startDate:self.startDate endDate:self.endDate];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateRunning, @"Invalid state");
 
    [[[self.mockCallProvider expect] andReturn:(id<XITSTimeSeriesCallProvider>)self.mockTimeSeriesCall] timeSeriesCall];
    [[self.mockTimeSeriesCall expect] setDelegate:[OCMArg any]];
    [[self.mockTimeSeriesCall expect] requestWithTopic:self.channel
                                             startDate:self.startDate
                                               endDate:self.endDate
                                              pageSize:kTimeSeriesPageSize
                                           pagingToken:nil];
    
    [self propagateResume];
    [self.mockCallProvider verify];
    [self.mockTimeSeriesCall verify];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateRunning, @"Invalid state");
 }

- (void)testXITSTimeSeriesIdleSuspendRequestListCancelResume {
    [self propagateSuspend];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateIdle, @"Invalid state");
    [self.timeSeries requestTimeSeriesItemsForChannel:self.channel startDate:self.startDate endDate:self.endDate];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateRunning, @"Invalid state");
    [self.timeSeries cancel];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
    [self propagateResume];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
}
 
- (void)testXITSTimeSeriesIdleSessionClosed {
    [self propagateClose];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
}
 
- (void)testXITSTimeSeriesSuspendedIdleSessionClosed {
    [self propagateSuspend];
    [self propagateClose];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
}
 
- (void)testXITSTimeSeriesSuspendedRunningSessionClosed {
    [self propagateSuspend];
    [self.timeSeries requestTimeSeriesItemsForChannel:self.channel startDate:self.startDate endDate:self.endDate];
    [self propagateClose];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
}

 
- (void)testXITSTimeSeriesRunningInitialCallCancel {
    [self testXITSTimeSeriesRequest];
    [[self.mockTimeSeriesCall expect] cancel];
    [self.timeSeries cancel];
    [self.mockTimeSeriesCall verify];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
}


- (void)testXITSTimeSeriesRunningInitialCallError {
    [self testXITSTimeSeriesRequest];

    NSError *error = [NSError errorWithDomain:@"sfgsdf" code:67 userInfo:nil];

    [(id<XITimeSeriesDelegate>)[self.mockDelegate expect] timeSeries:(id<XITimeSeries>)self.mockProxy didFailWithError:error];
    [self.timeSeries timeSeriesCall:(id<XITSTimeSeriesCall>)self.mockTimeSeriesCall didFailWithError:error];
    [self.mockTimeSeriesCall verify];

    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.timeSeries.error, error, @"Invalid error");
        XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateError, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}
 
- (void)testXITSTimeSeriesRunningInitialCallErrorWhileCanceled {
    [self testXITSTimeSeriesRequest];

    NSError *error = [NSError errorWithDomain:@"sfgsdf" code:67 userInfo:nil];
 
    [(id<XITimeSeriesDelegate>)[self.mockDelegate reject] timeSeries:(id<XITimeSeries>)self.mockProxy didFailWithError:error];
    [self.timeSeries timeSeriesCall:(id<XITSTimeSeriesCall>)self.mockTimeSeriesCall didFailWithError:error];
    [self.mockTimeSeriesCall verify];
 
    [self.timeSeries cancel];
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertNil(self.timeSeries.error, @"Invalid error");
        XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}


- (void)testXITSTimeSeriesRunningInitialReturnedAllElements {
    [self testXITSTimeSeriesRequest];

    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    
    XITSTimeSeriesMeta *meta = [[XITSTimeSeriesMeta alloc] initWithDictionary:@{@"timeSpent" : @3,
                                                                                @"start": self.startDateString,
                                                                                @"end" : self.endDateString,
                                                                                @"count" : @3} ];
 
    [(id<XITimeSeriesDelegate>)[self.mockDelegate expect] timeSeries:(id<XITimeSeries>)self.mockProxy didReceiveItems:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSArray *a = (NSArray *)obj;
        return a.count == 3 && [a containsObject:result1] && [a containsObject:result2] && [a containsObject:result3];
    }]];
    [self.timeSeries timeSeriesCall:(id<XITSTimeSeriesCall>)self.mockTimeSeriesCall
      didSucceedWithTimeSeriesItems:@[result1, result2, result3] meta:meta];
 
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateEnded, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXITSTimeSeriesRunningInitialReturnedAllElementsWhileCanceled {
    [self testXITSTimeSeriesRequest];
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    
    XITSTimeSeriesMeta *meta = [[XITSTimeSeriesMeta alloc] initWithDictionary:@{@"timeSpent" : @3,
                                                                                @"start": self.startDateString,
                                                                                @"end" : self.endDateString,
                                                                                @"count" : @3} ];
    
    [(id<XITimeSeriesDelegate>)[self.mockDelegate reject] timeSeries:[OCMArg any] didReceiveItems:[OCMArg any]];
    [self.timeSeries timeSeriesCall:(id<XITSTimeSeriesCall>)self.mockTimeSeriesCall
      didSucceedWithTimeSeriesItems:@[result1, result2, result3] meta:meta];
    
    [self.timeSeries cancel];
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateCanceled, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
 }


- (void)testXITSTimeSeriesRunningInitialReturnedNotAllOthers {
    [self testXITSTimeSeriesRequest];
    NSString *pagingToken = @"dsgsdfkgjh654kl6543kl6jh3456lk54jh634klj6h453kl6jh436k4h5sfgkfdshgsfdkjghdf";
 
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    NSObject *result4 = [NSObject new];
    NSObject *result5 = [NSObject new];
    NSObject *result6 = [NSObject new];
    NSObject *result7 = [NSObject new];
    NSObject *result8 = [NSObject new];
    NSObject *result9 = [NSObject new];
    NSObject *result10 = [NSObject new];
 
    XITSTimeSeriesMeta *meta = [[XITSTimeSeriesMeta alloc] initWithDictionary:@{@"timeSpent" : @3,
                                                                                @"start": self.startDateString,
                                                                                @"end" : self.endDateString,
                                                                                @"count" : @10,
                                                                                @"pagingToken" : pagingToken} ];
    
    [[[self.mockCallProvider expect] andReturn:(id<XITSTimeSeriesCallProvider>)self.mockTimeSeriesCall] timeSeriesCall];
    [[self.mockTimeSeriesCall expect] setDelegate:[OCMArg any]];
    [[self.mockTimeSeriesCall expect] requestWithTopic:self.channel
                                             startDate:self.startDate
                                               endDate:self.endDate
                                              pageSize:kTimeSeriesPageSize
                                           pagingToken:pagingToken];
    
    [self.timeSeries timeSeriesCall:(id<XITSTimeSeriesCall>)self.mockTimeSeriesCall
      didSucceedWithTimeSeriesItems:@[result1, result2, result3, result4, result5, result6, result7, result8, result9, result10] meta:meta];
 
    [self.mockCallProvider verify];
    [self.mockTimeSeriesCall verify];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateRunning, @"Invalid state");
}

- (void)testXITSTimeSeriesRunningResultsAreReturnedInMoreSteps {
    [self testXITSTimeSeriesRequest];
    NSString *pagingToken = @"dsgsdfkgjh654kl6543kl6jh3456lk54jh634klj6h453kl6jh436k4h5sfgkfdshgsfdkjghdf";
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    NSObject *result4 = [NSObject new];
    NSObject *result5 = [NSObject new];
    NSObject *result6 = [NSObject new];
    NSObject *result7 = [NSObject new];
    NSObject *result8 = [NSObject new];
    NSObject *result9 = [NSObject new];
    NSObject *result10 = [NSObject new];
    
    XITSTimeSeriesMeta *meta = [[XITSTimeSeriesMeta alloc] initWithDictionary:@{@"timeSpent" : @3,
                                                                                @"start": self.startDateString,
                                                                                @"end" : self.endDateString,
                                                                                @"count" : @10,
                                                                                @"pagingToken" : pagingToken} ];
    
    [[[self.mockCallProvider expect] andReturn:(id<XITSTimeSeriesCallProvider>)self.mockTimeSeriesCall] timeSeriesCall];
    [[self.mockTimeSeriesCall expect] setDelegate:[OCMArg any]];
    [[self.mockTimeSeriesCall expect] requestWithTopic:self.channel
                                             startDate:self.startDate
                                               endDate:self.endDate
                                              pageSize:kTimeSeriesPageSize
                                           pagingToken:pagingToken];
    
    [self.timeSeries timeSeriesCall:(id<XITSTimeSeriesCall>)self.mockTimeSeriesCall
      didSucceedWithTimeSeriesItems:@[result1, result2, result3, result4, result5, result6, result7, result8, result9, result10] meta:meta];
    
    [self.mockCallProvider verify];
    [self.mockTimeSeriesCall verify];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateRunning, @"Invalid state");
    
    NSObject *result11 = [NSObject new];
    NSObject *result12 = [NSObject new];
    NSObject *result13 = [NSObject new];
    
    meta = [[XITSTimeSeriesMeta alloc] initWithDictionary:@{@"timeSpent" : @3,
                                                                @"start": self.startDateString,
                                                                @"end" : self.endDateString,
                                                                @"count" : @3,
                                                                @"pagingToken" : pagingToken} ];
    
    [(id<XITimeSeriesDelegate>)[self.mockDelegate expect] timeSeries:(id<XITimeSeries>)self.mockProxy didReceiveItems:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSArray *a = (NSArray *)obj;
        return a.count == 13 && [a containsObject:result1] && [a containsObject:result2] && [a containsObject:result3] && [a containsObject:result5] &&
        [a containsObject:result5] && [a containsObject:result6] && [a containsObject:result7] && [a containsObject:result8] &&
        [a containsObject:result9] && [a containsObject:result10] && [a containsObject:result11] && [a containsObject:result12] &&
        [a containsObject:result13];
    }]];
    
    [self.timeSeries timeSeriesCall:(id<XITSTimeSeriesCall>)self.mockTimeSeriesCall
      didSucceedWithTimeSeriesItems:@[result11, result12, result13] meta:meta];
    
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.mockDelegate verify];
        XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateEnded, @"Invalid state");
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testXITSTimeSeriesRunningResultsAreReturnedInMoreStepsSuspendedInSecondStep {
    [self testXITSTimeSeriesRequest];
    NSString *pagingToken = @"dsgsdfkgjh654kl6543kl6jh3456lk54jh634klj6h453kl6jh436k4h5sfgkfdshgsfdkjghdf";
    
    NSObject *result1 = [NSObject new];
    NSObject *result2 = [NSObject new];
    NSObject *result3 = [NSObject new];
    NSObject *result4 = [NSObject new];
    NSObject *result5 = [NSObject new];
    NSObject *result6 = [NSObject new];
    NSObject *result7 = [NSObject new];
    NSObject *result8 = [NSObject new];
    NSObject *result9 = [NSObject new];
    NSObject *result10 = [NSObject new];
    
    XITSTimeSeriesMeta *meta = [[XITSTimeSeriesMeta alloc] initWithDictionary:@{@"timeSpent" : @3,
                                                                                @"start": self.startDateString,
                                                                                @"end" : self.endDateString,
                                                                                @"count" : @10,
                                                                                @"pagingToken" : pagingToken} ];
    
    [[[self.mockCallProvider expect] andReturn:(id<XITSTimeSeriesCallProvider>)self.mockTimeSeriesCall] timeSeriesCall];
    [[self.mockTimeSeriesCall expect] setDelegate:[OCMArg any]];
    [[self.mockTimeSeriesCall expect] requestWithTopic:self.channel
                                             startDate:self.startDate
                                               endDate:self.endDate
                                              pageSize:kTimeSeriesPageSize
                                           pagingToken:pagingToken];
    
    [self.timeSeries timeSeriesCall:(id<XITSTimeSeriesCall>)self.mockTimeSeriesCall
      didSucceedWithTimeSeriesItems:@[result1, result2, result3, result4, result5, result6, result7, result8, result9, result10] meta:meta];
    
    [self.mockCallProvider verify];
    [self.mockTimeSeriesCall verify];
    XCTAssertEqual(self.timeSeries.state, XITimeSeriesStateRunning, @"Invalid state");
    
    [[self.mockTimeSeriesCall expect] cancel];
    [self propagateSuspend];
    [self.mockTimeSeriesCall verify];
    
    [[[self.mockCallProvider expect] andReturn:(id<XITSTimeSeriesCallProvider>)self.mockTimeSeriesCall] timeSeriesCall];
    [[self.mockTimeSeriesCall expect] setDelegate:[OCMArg any]];
    [[self.mockTimeSeriesCall expect] requestWithTopic:self.channel
                                             startDate:self.startDate
                                               endDate:self.endDate
                                              pageSize:kTimeSeriesPageSize
                                           pagingToken:pagingToken];
    [self propagateResume];
    [self.mockCallProvider verify];
    [self.mockTimeSeriesCall verify];
    
}

- (void)testXITSTimeSeriesRunningSuspendAndResume {
    [self testXITSTimeSeriesRequest];
    
    [[self.mockTimeSeriesCall expect] cancel];
    [self propagateSuspend];
    [self.mockTimeSeriesCall verify];
    
    [[[self.mockCallProvider expect] andReturn:(id<XITSTimeSeriesCallProvider>)self.mockTimeSeriesCall] timeSeriesCall];
    [[self.mockTimeSeriesCall expect] setDelegate:[OCMArg any]];
    [[self.mockTimeSeriesCall expect] requestWithTopic:self.channel
                                             startDate:self.startDate
                                               endDate:self.endDate
                                              pageSize:kTimeSeriesPageSize
                                           pagingToken:nil];
    [self propagateResume];
    [self.mockCallProvider verify];
    [self.mockTimeSeriesCall verify];    
}

- (void)testProxyCreation {
    XCTAssert(YES, @"Pass");
    OCMockObject *mockInternal = [OCMockObject mockForProtocol:@protocol(XITimeSeries)];
    XITimeSeriesProxy *proxy = [[XITimeSeriesProxy alloc] initWithInternal:(id<XITimeSeries>)mockInternal];
    XCTAssert(proxy, @"Proxy creation failed");
}

- (void)testProxyProxying {
    XCTAssert(YES, @"Pass");
    OCMockObject *mockInternal = [OCMockObject mockForProtocol:@protocol(XITimeSeries)];
    OCMockObject *mockDelegate = [OCMockObject mockForProtocol:@protocol(XITimeSeriesDelegate)];
    XITimeSeriesProxy *proxy = [[XITimeSeriesProxy alloc] initWithInternal:(id<XITimeSeries>)mockInternal];
    
    [(id<XITimeSeries>)[[mockInternal expect] andReturnValue:OCMOCK_VALUE(XITimeSeriesStateIdle)] state];
    XCTAssertEqual(proxy.state, XITimeSeriesStateIdle, @"Invalid state forwarding");
    [mockInternal verify];
    
    [(id<XITimeSeries>)[[mockInternal expect] andReturnValue:OCMOCK_VALUE(XITimeSeriesStateRunning)] state];
    XCTAssertEqual(proxy.state, XITimeSeriesStateRunning, @"Invalid state forwarding");
    [mockInternal verify];
    
    [(id<XITimeSeries>)[[mockInternal expect] andReturnValue:OCMOCK_VALUE(XITimeSeriesStateEnded)] state];
    XCTAssertEqual(proxy.state, XITimeSeriesStateEnded, @"Invalid state forwarding");
    [mockInternal verify];
    
    [(id<XITimeSeries>)[[mockInternal expect] andReturnValue:OCMOCK_VALUE(XITimeSeriesStateError)] state];
    XCTAssertEqual(proxy.state, XITimeSeriesStateError, @"Invalid state forwarding");
    [mockInternal verify];
    
    [(id<XITimeSeries>)[[mockInternal expect] andReturnValue:OCMOCK_VALUE(XITimeSeriesStateCanceled)] state];
    XCTAssertEqual(proxy.state, XITimeSeriesStateCanceled, @"Invalid state forwarding");
    [mockInternal verify];
    
    [(id<XITimeSeries>)[[mockInternal expect] andReturn:mockDelegate] delegate];
    XCTAssertEqual(mockDelegate, proxy.delegate, @"Delegate forwarding error");
    [mockInternal verify];
    
    [(id<XITimeSeries>)[mockInternal expect] setDelegate:(id<XITimeSeriesDelegate>)mockDelegate];
    proxy.delegate = (id<XITimeSeriesDelegate>)mockDelegate;
    [mockInternal verify];
    
    NSError *error = [NSError errorWithDomain:@"sdgsd" code:79 userInfo:nil];
    [(id<XITimeSeries>)[[mockInternal expect] andReturn:error] error];
    XCTAssertEqual(error, proxy.error, @"Error forwarding error");
    [mockInternal verify];
    
    [(id<XITimeSeries>)[mockInternal expect] requestTimeSeriesItemsForChannel:self.channel startDate:self.startDate endDate:self.endDate];
    [proxy requestTimeSeriesItemsForChannel:self.channel startDate:self.startDate endDate:self.endDate];
    [mockInternal verify];
    
    [[mockInternal expect] cancel];
    [proxy cancel];
    [mockInternal verify];
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

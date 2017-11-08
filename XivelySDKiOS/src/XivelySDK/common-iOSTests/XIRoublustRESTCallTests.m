//
//  XIRoublustRESTCallTests.m
//  common-iOS
//
//  Created by vfabian on 13/02/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "XIRESTCall.h"
#import "XIRESTCallDelegate.h"
#import "XIRobustRESTCall.h"
#import "XITimer.h"
#import "XITimerProvider.h"
#import "XISdkConfig.h"

@interface XIRoublustRESTCallTests : XCTestCase <XIRobustRESTCallSimpleCallProvider, XITimerProvider, XIRESTCallDelegate>

@property(nonatomic, assign)BOOL positiveFinishCalled;
@property(nonatomic, assign)BOOL negativeFinishCalled;
@property(nonatomic, strong)NSData *positiveFinishResult;
@property(nonatomic, strong)NSError *negativeFinishError;

@property(nonatomic, assign)BOOL callTimeoutTimerReturned;
@property(nonatomic, strong)id<XITimer> callTimeoutTimer;
@property(nonatomic, strong)id<XITimer> waitTimer;
@property(nonatomic, strong)OCMockObject *callTimeoutTimerMock;
@property(nonatomic, strong)OCMockObject *waitTimerMock;
@property(nonatomic, strong)id<XIRESTCall> simpleRESTCall;
@property(nonatomic, strong)OCMockObject *simpleRESTCallMock;

@property(nonatomic, strong)XISdkConfig *config;

@end

@implementation XIRoublustRESTCallTests

@synthesize positiveFinishCalled;
@synthesize negativeFinishCalled;
@synthesize positiveFinishResult;
@synthesize negativeFinishError;

@synthesize callTimeoutTimer;
@synthesize waitTimer;
@synthesize callTimeoutTimerMock;
@synthesize waitTimerMock;
@synthesize simpleRESTCall;
@synthesize simpleRESTCallMock;
@synthesize callTimeoutTimerReturned;

@synthesize config = _config;


- (void)setUp {
    [super setUp];
    
    self.config = [XISdkConfig config];
    
    self.callTimeoutTimerMock = [OCMockObject mockForProtocol:@protocol(XITimer)];
    self.callTimeoutTimer = (id<XITimer>)(self.callTimeoutTimerMock);
    
    self.waitTimerMock = [OCMockObject mockForProtocol:@protocol(XITimer)];
    self.waitTimer = (id<XITimer>)(self.waitTimerMock);
    
    self.simpleRESTCallMock = [OCMockObject mockForProtocol:@protocol(XIRESTCall)];
    self.simpleRESTCall = (id<XIRESTCall>)(self.simpleRESTCallMock);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRESTCallCreation {
    XIRobustRESTCall *restCall = [[XIRobustRESTCall alloc] initWithSimpleCallProvider:self timerProvider:self config:self.config];
    XCTAssert(restCall, @"REST call not created");
    XCTAssertEqual(restCall.state, XIRESTCallStateIdle, @"REST initial state is invalid");
    XCTAssertNil(restCall.error, @"Error is filled");
    XCTAssertNil(restCall.result, @"Result is filled");
    XCTAssertNil(restCall.delegate, @"Delegate is filled");
}

- (void)testRESTCallStaticCreation {
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    XCTAssert(restCall, @"REST call not created");
    XCTAssertEqual(restCall.state, XIRESTCallStateIdle, @"REST initial state is invalid");
    XCTAssertNil(restCall.error, @"Error is filled");
    XCTAssertNil(restCall.result, @"Result is filled");
    XCTAssertNil(restCall.delegate, @"Delegate is filled");
}

- (void)testRESTCallDelegateSetting {
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.delegate = self;
    XCTAssertEqual(self, restCall.delegate, @"Wrongly set delegate");
}

- (void)testRESTCallStartGetMethod {
    NSString *urlToCall = @"http://www.logmein.com";
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.delegate = self;
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodGET headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodGET headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];

    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    //test if mock are called back again
    [restCall startWithURL:urlToCall method:XIRESTCallMethodGET headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
}

- (void)testRESTCallStartPostMethod {
    NSString *urlToCall = @"http://www.logmein.com";
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.delegate = self;
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
}

- (void)testRESTCallStartPutMethod {
    NSString *urlToCall = @"http://www.logmein.com";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.delegate = self;
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
}

- (void)testRESTCallStartDeleteMethod {
    NSString *urlToCall = @"http://www.logmein.com";
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.delegate = self;
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodDELETE headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodDELETE headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
}

- (void)testRESTCallPositiveResult {
    NSString *urlToCall = @"http://www.logmein.com";
    NSString *resultString = @"tttttttttttttttitttttittttt";
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.delegate = self;
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    [[self.callTimeoutTimerMock expect] cancel];
    [restCall XIRESTCall:self.simpleRESTCall didFinishWithData:[resultString dataUsingEncoding:NSUTF8StringEncoding] httpStatusCode:200];
    [self.callTimeoutTimerMock verify];
    
    XCTAssertTrue(self.positiveFinishCalled, @"Positive finish is not called back");
    NSString *responseString = [[NSString alloc] initWithData:self.positiveFinishResult encoding:NSUTF8StringEncoding];
    XCTAssert([responseString isEqualToString:resultString], @"Wrong result given back");
}

- (void)testRESTCallNegativeResult {
    NSString *urlToCall = @"http://www.logmein.com";
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.maximumRetryCount = 3;
    
    restCall.delegate = self;
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];

    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    for (int i = 0; i < restCall.maximumRetryCount; i++) {
        [[self.waitTimerMock expect] setDelegate:restCall];
        [[self.waitTimerMock expect] startWithTimeout:restCall.retryWaitTime periodic:NO];
        [restCall XIRESTCall:self.simpleRESTCall didFinishWithError:[NSError errorWithDomain:@"test" code:1009 userInfo:nil]];
        [self.waitTimerMock verify];
        XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
        
        [[self.simpleRESTCallMock expect] setDelegate:restCall];
        [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
        [restCall XITimerDidTick:self.waitTimer];
        [self.simpleRESTCallMock verify];
        XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    }
    
    [[self.callTimeoutTimerMock expect] cancel];
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [restCall XIRESTCall:self.simpleRESTCall didFinishWithError:[NSError errorWithDomain:@"test" code:1009 userInfo:nil]];
    [self.callTimeoutTimerMock verify];
    XCTAssertTrue(self.negativeFinishCalled, @"Positive finish is not called back");
    XCTAssertEqual(1009, self.negativeFinishError.code, @"Invalid error returned");
}

- (void)testRESTCallCancelOnWaitingToCallAgain {
    NSString *urlToCall = @"http://www.logmein.com";
    NSString *resultString = @"tttttttttttttttitttttittttt";
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.maximumRetryCount = 3;
    restCall.delegate = self;
    
    [restCall cancel];
    XCTAssertEqual(restCall.state, XIRESTCallStateIdle);
    
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    [[self.waitTimerMock expect] setDelegate:restCall];
    [[self.waitTimerMock expect] startWithTimeout:restCall.retryWaitTime periodic:NO];
    [restCall XIRESTCall:self.simpleRESTCall didFinishWithError:[NSError errorWithDomain:@"test" code:1009 userInfo:nil]];
    [self.waitTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    [[self.simpleRESTCallMock expect] cancel];
    [[self.waitTimerMock expect] cancel];
    [[self.callTimeoutTimerMock expect] cancel];
    [restCall cancel];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    [self.waitTimerMock verify];
    
    XCTAssertEqual(restCall.state, XIRESTCallStateCanceled);
    
    
    [restCall XIRESTCall:self.simpleRESTCall didFinishWithData:[resultString dataUsingEncoding:NSUTF8StringEncoding] httpStatusCode:200];
    XCTAssertFalse(self.positiveFinishCalled, @"Positive callback called back after cancel");
    XCTAssertEqual(restCall.state, XIRESTCallStateCanceled);
    
    [restCall cancel];
    XCTAssertEqual(restCall.state, XIRESTCallStateCanceled);
}

- (void)testRESTCallCancel {
    NSString *urlToCall = @"http://www.logmein.com";
    NSString *resultString = @"tttttttttttttttitttttittttt";
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.delegate = self;
    
    [restCall cancel];
    XCTAssertEqual(restCall.state, XIRESTCallStateIdle);
    
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    [[self.simpleRESTCallMock expect] cancel];
    [[self.callTimeoutTimerMock expect] cancel];
    [restCall cancel];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateCanceled);
    
    
    [restCall XIRESTCall:self.simpleRESTCall didFinishWithData:[resultString dataUsingEncoding:NSUTF8StringEncoding] httpStatusCode:200];
    XCTAssertFalse(self.positiveFinishCalled, @"Positive callback called back after cancel");
    XCTAssertEqual(restCall.state, XIRESTCallStateCanceled);
    
    [restCall cancel];
    XCTAssertEqual(restCall.state, XIRESTCallStateCanceled);
}

- (void)testRESTCallFinishedStateCancelFinished {
    NSString *urlToCall = @"http://www.logmein.com";
    NSString *resultString = @"tttttttttttttttitttttittttt";
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.delegate = self;
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    [[self.callTimeoutTimerMock expect] cancel];
    [restCall XIRESTCall:self.simpleRESTCall didFinishWithData:[resultString dataUsingEncoding:NSUTF8StringEncoding] httpStatusCode:200];
    [self.callTimeoutTimerMock verify];
    
    XCTAssertTrue(self.positiveFinishCalled, @"Positive finish is not called back");
    NSString *responseString = [[NSString alloc] initWithData:self.positiveFinishResult encoding:NSUTF8StringEncoding];
    XCTAssert([responseString isEqualToString:resultString], @"Wrong result given back");
    
    [restCall cancel];
    XCTAssertTrue(self.positiveFinishCalled, @"Positive finish is not called back");
}

- (void)testRESTCallTimeoutOnCalling {
    NSString *urlToCall = @"http://www.logmein.com";
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.delegate = self;
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    [[self.callTimeoutTimerMock expect] cancel];
    [[self.simpleRESTCallMock expect] cancel];
    [restCall XITimerDidTick:self.callTimeoutTimer];
    [self.callTimeoutTimerMock verify];
    [[self.simpleRESTCallMock expect] cancel];
    XCTAssertTrue(self.negativeFinishCalled, @"NEgative finish is not called back");
    
    XCTAssertEqual(self.negativeFinishError.code, XIRobustRESTCall_TimeoutErrorCode, @"Wrong timeout error code");
}

- (void)testRESTCallTimeoutOnWaitingToCall {
    NSString *urlToCall = @"http://www.logmein.com";
    
    XIRobustRESTCall *restCall = [XIRobustRESTCall restCallInternalWithSimpleCallProvider:self timerProvider:self config:self.config];
    restCall.maximumRetryCount = 3;
    restCall.delegate = self;
    
    [[self.simpleRESTCallMock expect] startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [[self.simpleRESTCallMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] setDelegate:restCall];
    [[self.callTimeoutTimerMock expect] startWithTimeout:self.config.httpResponseTimeout periodic:NO];
        [restCall startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [self.simpleRESTCallMock verify];
    [self.callTimeoutTimerMock verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    [[self.waitTimerMock expect] setDelegate:restCall];
    [[self.waitTimerMock expect] startWithTimeout:restCall.retryWaitTime periodic:NO];
        [restCall XIRESTCall:self.simpleRESTCall didFinishWithError:[NSError errorWithDomain:@"test" code:1009 userInfo:nil]];
    [self.waitTimerMock verify];
    
    [[self.callTimeoutTimerMock expect] cancel];
    [[self.waitTimerMock expect] cancel];
    [[self.simpleRESTCallMock expect] cancel];
        [restCall XITimerDidTick:self.callTimeoutTimer];
    [self.callTimeoutTimerMock verify];
    [self.waitTimerMock verify];

    XCTAssertTrue(self.negativeFinishCalled, @"NEgative finish is not called back");
    XCTAssertEqual(self.negativeFinishError.code, XIRobustRESTCall_TimeoutErrorCode, @"Wrong timeout error code");
}

#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode{
    self.positiveFinishCalled = YES;
    self.positiveFinishResult = data;
}

- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    self.negativeFinishCalled = YES;
    self.negativeFinishError = error;
}

#pragma mark -
#pragma mark XIRobustRESTCallSimpleCallProvider

- (id<XIRESTCall>)getEmptySimpleRESTCall {
    return self.simpleRESTCall;
}

#pragma mark -
#pragma mark XITimerProvider
- (id<XITimer>)getTimer {
    if (!self.callTimeoutTimerReturned) {
        self.callTimeoutTimerReturned = YES;
        return self.callTimeoutTimer;
    } else {
        return self.waitTimer;
    }
}


@end

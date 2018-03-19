//
//  XISimpleRESTCallTests.m
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XIRESTCall.h"
#import "XIRESTCallDelegate.h"
#import "XISimpleRESTCall.h"
#import <OCMock/OCMock.h>
#import "XIRESTCallResponseRecognizer.h"

@interface XISimpleRESTCallTests : XCTestCase <XIRESTCallDelegate>

@property(nonatomic, strong)NSURLSession *urlSession;
@property(nonatomic, strong)OCMockObject *mockUrlSession;
@property(nonatomic, strong)OCMockObject *mockJwtRecognizer;
@property(nonatomic, strong)XCTestExpectation *expectation;

@property(nonatomic, assign)BOOL positiveFinishCalled;
@property(nonatomic, assign)BOOL negativeFinishCalled;
@property(nonatomic, strong)NSData *positiveFinishResult;
@property(nonatomic, strong)NSError *negativeFinishError;


@end

@implementation XISimpleRESTCallTests

@synthesize urlSession;
@synthesize mockUrlSession;
@synthesize expectation;
@synthesize positiveFinishCalled;
@synthesize negativeFinishCalled;
@synthesize positiveFinishResult;
@synthesize negativeFinishError;


- (void)setUp {
    [super setUp];
    
    self.mockUrlSession = [OCMockObject mockForClass:[NSURLSession class]];
    self.urlSession = (NSURLSession *)(self.mockUrlSession);
    self.mockJwtRecognizer = [OCMockObject mockForProtocol:@protocol(XIRESTCallResponseRecognizer)];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRESTCallCreation {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    XISimpleRESTCall *restCall = [[XISimpleRESTCall alloc] initWithURLSession:self.urlSession
                                                       defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                  responseRecognizers:nil];
    XCTAssert(restCall, @"REST call not created");
    XCTAssertEqual(restCall.state, XIRESTCallStateIdle, @"REST initial state is invalid");
    XCTAssertNil(restCall.error, @"Error is filled");
    XCTAssertNil(restCall.result, @"Result is filled");
    XCTAssertNil(restCall.delegate, @"Delegate is filled");
}

- (void)testRESTCallStaticCreation {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    XISimpleRESTCall *restCall = [[XISimpleRESTCall alloc] initWithURLSession:self.urlSession
                                                       defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                          responseRecognizers:nil];
    XCTAssert(restCall, @"REST call not created");
    XCTAssertEqual(restCall.state, XIRESTCallStateIdle, @"REST initial state is invalid");
    XCTAssertNil(restCall.error, @"Error is filled");
    XCTAssertNil(restCall.result, @"Result is filled");
    XCTAssertNil(restCall.delegate, @"Delegate is filled");
}

- (void)testRESTCallDelegateSetting {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    XISimpleRESTCall *restCall = [[XISimpleRESTCall alloc] initWithURLSession:self.urlSession
                                                       defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                          responseRecognizers:nil];
    restCall.delegate = self;
    XCTAssertEqual(self, restCall.delegate, @"Wrongly set delegate");
}

- (void)testRESTCallStartGetMethod {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:nil];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"GET"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        return obj != nil;
    }]];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodGET headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.mockUrlSession verify];
    [dataTask verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    [[[self.mockUrlSession reject] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        return YES;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        return YES;
    }]];
    
    [self.mockUrlSession verify];
    [[dataTask stub] cancel];
}

- (void)testRESTCallStartPostMethod {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    NSString *body = @"aaaaaaaaaaa";
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:nil];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"POST"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        NSString *requestBody = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
        returnValue = returnValue && [requestBody isEqualToString:body];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        return obj != nil;
    }]];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self.mockUrlSession verify];
    [dataTask verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    [[dataTask stub] cancel];
}

- (void)testRESTCallStartPutMethod {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:nil];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"PUT"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        return obj != nil;
    }]];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPUT headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.mockUrlSession verify];
    [dataTask verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    [[dataTask stub] cancel];
}

- (void)testRESTCallStartDeleteMethod {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:nil];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"DELETE"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        return obj != nil;
    }]];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodDELETE headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.mockUrlSession verify];
    [dataTask verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    [[dataTask stub] cancel];
}

- (void)testRESTCallPositiveResult {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    NSString *resultString = @"tttttttttttttttitttttittttt";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    __block void (^callbackMethod)(NSData *data, NSURLResponse *response, NSError *error) = nil;
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:nil];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"POST"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        callbackMethod = (void (^)(NSData *data, NSURLResponse *response, NSError *error))obj;
        return obj != nil;
    }]];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.mockUrlSession verify];
    [dataTask verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    callbackMethod([resultString dataUsingEncoding:NSUTF8StringEncoding], nil, nil);
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        XCTAssertTrue(self.positiveFinishCalled, @"Positive finish is not called back");
        NSString *responseString = [[NSString alloc] initWithData:self.positiveFinishResult encoding:NSUTF8StringEncoding];
        XCTAssert([responseString isEqualToString:resultString], @"Wrong result given back");
        
        [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
        XCTAssertEqual(restCall.state, XIRESTCallStateFinishedWithSuccess, @"Wrong state after trying to restart");
        
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testRESTCallNegativeResult {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    __block void (^callbackMethod)(NSData *data, NSURLResponse *response, NSError *error) = nil;
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:nil];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"POST"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        callbackMethod = (void (^)(NSData *data, NSURLResponse *response, NSError *error))obj;
        return obj != nil;
    }]];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.mockUrlSession verify];
    [dataTask verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    callbackMethod(nil, nil, [NSError errorWithDomain:@"test" code:1009 userInfo:nil]);
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        XCTAssertTrue(self.negativeFinishCalled, @"Positive finish is not called back");
        XCTAssertEqual(1009, self.negativeFinishError.code, @"Invalid error returned");
        
        [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
        XCTAssertEqual(restCall.state, XIRESTCallStateFinishedWithError, @"Wrong state after trying to restart");
        
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testRESTCallCancel {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    __block void (^callbackMethod)(NSData *data, NSURLResponse *response, NSError *error) = nil;
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:nil];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"POST"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        callbackMethod = (void (^)(NSData *data, NSURLResponse *response, NSError *error))obj;
        return obj != nil;
    }]];
    
    [restCall cancel];
    XCTAssertEqual(restCall.state, XIRESTCallStateIdle);
    
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
    [self.mockUrlSession verify];
    [dataTask verify];
    
    [[dataTask expect] cancel];
    [restCall cancel];
    XCTAssertEqual(restCall.state, XIRESTCallStateCanceled);
    [dataTask verify];
    
    callbackMethod([urlToCall dataUsingEncoding:NSUTF8StringEncoding], nil, nil);
    XCTAssertFalse(self.positiveFinishCalled, @"Positive callback called back after cancel");
    
    
    [restCall cancel];
    XCTAssertEqual(restCall.state, XIRESTCallStateCanceled);
}

- (void)testRESTCallFinishedStateCancel {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    NSString *resultString = @"tttttttttttttttitttttittttt";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    __block void (^callbackMethod)(NSData *data, NSURLResponse *response, NSError *error) = nil;
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:nil];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"POST"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        callbackMethod = (void (^)(NSData *data, NSURLResponse *response, NSError *error))obj;
        return obj != nil;
    }]];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.mockUrlSession verify];
    [dataTask verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    callbackMethod([resultString dataUsingEncoding:NSUTF8StringEncoding], nil, nil);
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        XCTAssertTrue(self.positiveFinishCalled, @"Positive finish is not called back");
        NSString *responseString = [[NSString alloc] initWithData:self.positiveFinishResult encoding:NSUTF8StringEncoding];
        XCTAssert([responseString isEqualToString:resultString], @"Wrong result given back");
        
        [restCall cancel];
        XCTAssertEqual(restCall.state, XIRESTCallStateFinishedWithSuccess);
        
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRESTCallDefaultHeaders {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{@"aa" : @"bb", @"cc" : @"dd", @"Authorization" : @"555555"}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    __block void (^callbackMethod)(NSData *data, NSURLResponse *response, NSError *error) = nil;
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:nil];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"POST"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"aa"] isEqualToString:@"bb"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"cc"] isEqualToString:@"dd"];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        callbackMethod = (void (^)(NSData *data, NSURLResponse *response, NSError *error))obj;
        return obj != nil;
    }]];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.mockUrlSession verify];
    [dataTask verify];
}

- (void)testRESTResponseRecognizers {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    [[[mockDefaultHeadersProvider stub] andReturn:@{}] defaultHeaders];
    NSString *urlToCall = @"http://www.logmein.com";
    NSString *resultString = @"tttttttttttttttitttttittttt";
    
    OCMockObject *dataTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
    [[dataTask expect] resume];
    
    __block void (^callbackMethod)(NSData *data, NSURLResponse *response, NSError *error) = nil;
    
    XISimpleRESTCall *restCall = [XISimpleRESTCall restCallInternalWithURLSession:self.urlSession
                                                           defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider
                                                              responseRecognizers:@[self.mockJwtRecognizer]];
    restCall.delegate = self;
    [[[self.mockUrlSession expect] andReturn:dataTask] dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        BOOL returnValue = [request.URL.absoluteString isEqualToString:urlToCall];
        returnValue = returnValue && [request.HTTPMethod isEqualToString:@"POST"];
        returnValue = returnValue && [request.allHTTPHeaderFields[@"Authorization"] isEqualToString:@"aa:aa"];
        return returnValue;
    }] completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        callbackMethod = (void (^)(NSData *data, NSURLResponse *response, NSError *error))obj;
        return obj != nil;
    }]];
    [restCall startWithURL:urlToCall method:XIRESTCallMethodPOST headers:@{@"Authorization" : @"aa:aa"} body:nil];
    
    [self.mockUrlSession verify];
    [dataTask verify];
    XCTAssertEqual(restCall.state, XIRESTCallStateRunning, @"Call is not in running state when start is called");
    
    [[self.mockJwtRecognizer expect] handleUrlResponse:[OCMArg any]];
    callbackMethod([resultString dataUsingEncoding:NSUTF8StringEncoding], nil, nil);
    self.expectation = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [self.mockJwtRecognizer verify];
        [self.expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}


#pragma mark -
#pragma mark XIRESTCallDelegate
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode{
    self.positiveFinishCalled = YES;
    self.positiveFinishResult = data;
    XCTAssertNil(call.error, @"wrongly filled error");
    XCTAssertEqual(call.state, XIRESTCallStateFinishedWithSuccess, @"Wrong end state");
}

- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error {
    self.negativeFinishCalled = YES;
    self.negativeFinishError = error;
    XCTAssertNil(call.result, @"wrongly filled data");
    XCTAssertNotNil(call.error, @"Not having error in error state");
    XCTAssertEqual(call.state, XIRESTCallStateFinishedWithError, @"Wrong end state");
}

@end

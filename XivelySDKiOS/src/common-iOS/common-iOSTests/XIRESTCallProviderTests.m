//
//  XIRESTCallProviderTests.m
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIRESTCall.h"
#import "XIRESTCallDelegate.h"
#import "XIRESTCallProvider.h"
#import "XIRESTCallProviderInternal.h"
#import "XIRobustRESTCall.h"
#import "XITimer.h"
#import "XITimerProvider.h"
#import "XISdkConfig.h"

@interface XIRESTCallProviderTests : XCTestCase

@property(nonatomic, strong)XISdkConfig *config;

@end

@implementation XIRESTCallProviderTests

@synthesize config = _config;

- (void)setUp {
    self.config = [XISdkConfig configWithHTTPResponseTimeout:5
                                                      urlSession:[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]
                                              mqttConnectTimeout:1 mqttRetryAttempt:2
                                             mqttWaitOnReconnect:3];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIRESTCallProviderCreation {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    XIRESTCallProviderInternal *provider = [[XIRESTCallProviderInternal alloc] initWithConfig:self.config defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider responseRecognizers:nil];
    XCTAssert(provider, @"Provider is not created");
}

- (void)testXIRESTCallProviderStaticCreation {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    XIRESTCallProviderInternal *provider = [[XIRESTCallProviderInternal alloc] initWithConfig:self.config defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider responseRecognizers:nil];
    XCTAssert(provider, @"Provider is not created");
}

- (void)testXIRESTCallProviderGettingACall {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    XIRESTCallProviderInternal *provider = [[XIRESTCallProviderInternal alloc] initWithConfig:self.config defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider responseRecognizers:nil];
    XCTAssert(provider, @"Provider is not created");
    
    id<XIRESTCall> call = [provider getEmptyRESTCall];
    XCTAssert(call, @"Call is missing");
    XCTAssert([call conformsToProtocol:@protocol(XIRESTCall)], @"Call does not conform XIRESTCall interface");
}

- (void)testXIRESTCallProviderGettingASimpleCall {
    OCMockObject *mockDefaultHeadersProvider = [OCMockObject mockForClass:[XIRESTDefaultHeadersProvider class]];
    XIRESTCallProviderInternal *provider = [[XIRESTCallProviderInternal alloc] initWithConfig:self.config defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)mockDefaultHeadersProvider responseRecognizers:nil];
    XCTAssert(provider, @"Provider is not created");
    
    id<XIRESTCall> call = [provider getEmptySimpleRESTCall];
    XCTAssert(call, @"Call is missing");
    XCTAssert([call conformsToProtocol:@protocol(XIRESTCall)], @"Call does not conform XIRESTCall interface");
}

@end

//
//  XISdkConfigTest.m
//  common-iOS
//
//  Created by vfabian on 26/05/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "XISdkConfig.h"
#import <OCMock/OCMock.h>


@interface XISdkConfigTest : XCTestCase

@end

@implementation XISdkConfigTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConfigCreation {
    long httpResponseTimeout = 1;
    NSURLSession *urlSession = (NSURLSession *)[OCMockObject mockForClass:[NSURLSession class]];
    long mqttConnectTimeout = 4;
    int mqttRetryAttempt = 5;
    long mqttWaitOnReconnect = 6;
    XISdkConfig *config = [[XISdkConfig alloc] initWithHTTPResponseTimeout:httpResponseTimeout
                                                                        urlSession:urlSession
                                                                mqttConnectTimeout:mqttConnectTimeout
                                                                  mqttRetryAttempt:mqttRetryAttempt
                                                               mqttWaitOnReconnect:mqttWaitOnReconnect];
    
    XCTAssert(config, @"Config creation failed");
    XCTAssertEqual(httpResponseTimeout, config.httpResponseTimeout, @"httpResponseTimeout setting is invalid");
    XCTAssertEqual(urlSession, config.urlSession, @"urlSession setting is invalid");
    XCTAssertEqual(mqttConnectTimeout, config.mqttConnectTimeout, @"mqttConnectTimeout setting is invalid");
    XCTAssertEqual(mqttRetryAttempt, config.mqttRetryAttempt, @"mqttRetryAttempt setting is invalid");
    XCTAssertEqual(mqttWaitOnReconnect, config.mqttWaitOnReconnect, @"mqttWaitOnReconnect setting is invalid");
}

- (void)testConfigStaticCreation {
    long httpResponseTimeout = 1;
    NSURLSession *urlSession = (NSURLSession *)[OCMockObject mockForClass:[NSURLSession class]];
    long mqttConnectTimeout = 4;
    int mqttRetryAttempt = 5;
    long mqttWaitOnReconnect = 6;
    XISdkConfig *config = [XISdkConfig configWithHTTPResponseTimeout:httpResponseTimeout
                                                                        urlSession:urlSession
                                                                mqttConnectTimeout:mqttConnectTimeout
                                                                  mqttRetryAttempt:mqttRetryAttempt
                                                               mqttWaitOnReconnect:mqttWaitOnReconnect];
    
    XCTAssert(config, @"Config creation failed");
    XCTAssertEqual(httpResponseTimeout, config.httpResponseTimeout, @"httpResponseTimeout setting is invalid");
    XCTAssertEqual(urlSession, config.urlSession, @"urlSession setting is invalid");
    XCTAssertEqual(mqttConnectTimeout, config.mqttConnectTimeout, @"mqttConnectTimeout setting is invalid");
    XCTAssertEqual(mqttRetryAttempt, config.mqttRetryAttempt, @"mqttRetryAttempt setting is invalid");
    XCTAssertEqual(mqttWaitOnReconnect, config.mqttWaitOnReconnect, @"mqttWaitOnReconnect setting is invalid");
}

@end

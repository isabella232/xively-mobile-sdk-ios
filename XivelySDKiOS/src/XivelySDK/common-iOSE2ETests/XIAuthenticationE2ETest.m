//
//  XIAuthenticationE2ETest.m
//  common-iOS
//
//  Created by gszajko on 08/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "XIAuthentication.h"
#import "XISdkConfig.h"
#import "XISdkConfig+Selector.h"
#import "XITestConfig.h"

@interface XIAuthenticationE2ETest : XCTestCase
@property (nonatomic, strong) XISdkConfig* config;
@property (nonatomic, strong) XIAuthentication* auth;
@property (nonatomic, strong) id delegate;
@end

@implementation XIAuthenticationE2ETest

- (void)setUp {
    [super setUp];
    
    self.config = [[XISdkConfig alloc] initWithEnvironment: XIEnvironmentLive];
    self.auth = [[XIAuthentication alloc] initWithSdkConfig: self.config];
    self.delegate = OCMStrictProtocolMock(@protocol(XIAuthenticationDelegate));
    self.auth.delegate = self.delegate;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testLoginWithBadCredentials {
    
    XCTestExpectation* failed = [self expectationWithDescription: @"didFailWithError"];
    OCMExpect([self.delegate authentication: OCMOCK_ANY didFailWithError: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [failed fulfill];
    });
    
    [self.auth requestLoginWithUsername: @"" password: @"" accountId: @""];
    
    [self waitForExpectationsWithTimeout: 2.f handler: nil];
    
    OCMVerifyAll(self.delegate);
}

- (void)testLoginWithValidEndUserCredentials {
    
    XCTestExpectation* created = [self expectationWithDescription: @"didCreateSession"];
    OCMExpect([self.delegate authentication: OCMOCK_ANY didCreateSession: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [created fulfill];
    });

    [self.auth requestLoginWithUsername: endUserName
                               password: endUserPassword
                              accountId: endUserAccountId];
    
    [self waitForExpectationsWithTimeout: 2.f handler: nil];
    
    OCMVerifyAll(self.delegate);
}

- (void)testLoginWithValidAccountUserCredentials {
    
    XCTestExpectation* created = [self expectationWithDescription: @"didCreateSession"];
    OCMExpect([self.delegate authentication: OCMOCK_ANY didCreateSession: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [created fulfill];
    });
    
    [self.auth requestLoginWithUsername: accountUserName
                               password: accountUserPassword
                              accountId: accountUserAccountId];
    
    [self waitForExpectationsWithTimeout: 2.f handler: nil];
    
    OCMVerifyAll(self.delegate);
}


@end

//
//  XICOAuthenticationTests.m
//  common-iOS
//
//  Created by gszajko on 26/06/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import <OCMock/OCMockObject.h>

#import "XIAuthentication.h"
#import "XIServicesConfig.h"
#import "XIAccess.h"
#import <XivelySDK/XISdkConfig+Selector.h>
#import "XICOResolveUserCall.h"
#import <XivelySDK/XICommonError.h>

@interface XICOAuthenticationTests : XCTestCase
@property (strong, nonatomic) id<XICOAuthenticating>        authentication;
@property (strong, nonatomic) OCMockObject                  *delegate;
@property (strong, nonatomic) id<XIRESTCallProvider>        restCallProvider;
@property (strong, nonatomic) id<XIRESTCall>                call;
@property (strong, nonatomic) XIServicesConfig*             servicesConfig;
@property (strong, nonatomic) XISdkConfig*                  config;
@property (strong, nonatomic) XIAccess*                     access;
@property (strong, nonatomic) OCMockObject    *authenticationCall;
@property (strong, nonatomic) OCMockObject        *resolveUserCall;

@property (strong, nonatomic)NSString *emailAddress;
@property (strong, nonatomic)NSString *password;
@property (strong, nonatomic)NSString *accountId;
@property (strong, nonatomic)NSString *jwt;
@property (strong, nonatomic)NSString *idmUserId;

@property(nonatomic, strong)XCTestExpectation *expectation;
@end

@implementation XICOAuthenticationTests

- (void)setUp {
    [super setUp];
    
    self.emailAddress = @"sdfkgjsdfklsjdfhgfksdjlgdfskljgdhflk";
    self.password = @"dskjsdkjldshfkjg";
    self.accountId = @"sdkgjsdhgklshgkdgdsfkgjh";
    self.idmUserId = @"03905a0f-0050-4e85-965e-bf9bcaf48083";
    
    self.access = [XIAccess new];
    self.access.accountId = self.accountId;
    self.access.mqttPassword = @"sdkghjgfjhgfhgfjsdhgklshgkdgdsfkgjh";
    self.access.mqttDeviceId = @"sdkghjgfhjgfhgfghjfhgfjsdhgklshgkdgdsfkgjh";
    self.jwt = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6ImY3NDA0MGQyLWE1ODUtNDVmMC1hZWEzLTY1YjFjOTYyNzIxMCIsInVzZXJJZCI6IjAzOTA1YTBmLTAwNTAtNGU4NS05NjVlLWJmOWJjYWY0ODA4MyIsImV4cGlyZXMiOjE0MzU4Mzg4MzA0NjMsImNlcnQiOiI5ZWMyZDQ2My1jYTY3LTRkZTctYjQ0Mi03YTk4Y2RiMjIwYTAiLCJyZW5ld2FsS2V5IjoidHMzR3d2VkNLZ1BYQXJlOEx2VGVDUT09IiwiYWNjb3VudElkIjoiNTgzOWJkNWUtZGQ1Ni00NDgzLWJlMTAtN2UwMTJlMDk2ZWE3In0.DfPCQUBMbh8yhVjG6F0njqb45WdcUKA-ysHkRPwHCeA";
    
    _config = OCMStrictClassMock([XISdkConfig class]);
    _servicesConfig = OCMStrictClassMock([XIServicesConfig class]);
    _restCallProvider = OCMStrictProtocolMock(@protocol(XIRESTCallProvider));
    _call = OCMStrictProtocolMock(@protocol(XIRESTCall));
    _delegate = OCMStrictProtocolMock(@protocol(XIAuthenticationDelegate));
    
    self.authenticationCall = [OCMockObject mockForProtocol:@protocol(XICOAuthenticationCall)];
    self.resolveUserCall = [OCMockObject mockForProtocol:@protocol(XICOResolveUserCall)];
    
    [[self.authenticationCall stub] setDelegate:[OCMArg any]];
    [[self.resolveUserCall stub] setDelegate:[OCMArg any]];
    
    _authentication = [[XICOAuthentication alloc] initWithLogger: nil
                                                restCallProvider: _restCallProvider
                                                  servicesConfig: _servicesConfig
                                                           proxy: nil
                                                          access: _access
                                              authenticationCall:(id<XICOAuthenticationCall>)self.authenticationCall
                                                  resolveUserCall:(id<XICOResolveUserCall>)self.resolveUserCall];
    [_authentication setDelegate:(id<XIAuthenticationDelegate>)_delegate];
    XCTAssertEqual(_authentication.state, XIAuthenticationStateIdle);
}

- (void)tearDown {
    [super tearDown];
    [[self.authenticationCall stub] cancel];
    [[self.resolveUserCall stub] cancel];
}

- (void)testRequestTokenWithUsernameExpectPostToLoginUrl {
    
    [[self.authenticationCall expect] requestLoginWithEmailAddress:self.emailAddress
                                                                          password:self.password
                                                                         accountId:self.accountId];
    
    [_authentication requestSessionWithUsername: self.emailAddress
                                       password: self.password
                                      accountId: self.accountId];
    
    [(OCMockObject *)self.authenticationCall verify];
    XCTAssertEqual(_authentication.state, XIAuthenticationStateRunning);
}

- (void)testRequestTokenWithUsernameExpectPostToLoginUrlAndCancel {
    
    [self testRequestTokenWithUsernameExpectPostToLoginUrl];
    
    [[self.authenticationCall expect] cancel];
    [[self.resolveUserCall expect] cancel];
    [_authentication cancel];
    [self.authenticationCall verify];
    [self.resolveUserCall verify];
    
    XCTAssertEqual(_authentication.state, XIAuthenticationStateCanceled);
}

- (void)testValidResponseToTokenWithUsernameRequestExpectTokenReceived {
    [self testRequestTokenWithUsernameExpectPostToLoginUrl];
    
    [[self.resolveUserCall expect] requestUserWithAccountId:self.accountId idmUserId:self.idmUserId];
    [(id<XICOAuthenticationCallDelegate>)_authentication authenticationCall:(id<XICOAuthenticationCall>)self.authenticationCall didReceiveJwt:self.jwt];
    [self.resolveUserCall verify];
    
    XCTAssert([self.access.jwt isEqualToString:self.jwt], @"JWT setting failed");
    XCTAssertEqual(_authentication.state, XIAuthenticationStateRunning);
}

- (void)testValidResponseToTokenWithUsernameRequestExpectInvalidTokenReceived {
    [self testRequestTokenWithUsernameExpectPostToLoginUrl];
    
    [[self.delegate expect] authentication:[OCMArg any] didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *err = (NSError *)obj;
        return XIErrorInternal == err.code;
    }]];
    
    [(id<XICOAuthenticationCallDelegate>)_authentication authenticationCall:(id<XICOAuthenticationCall>)self.authenticationCall didReceiveJwt:nil];
    [self.resolveUserCall verify];
    XCTAssertEqual(_authentication.state, XIAuthenticationStateError);
    
    self.expectation = [self expectationWithDescription:@"testValidResponseToTokenWithUsernameRequestExpectInvalidTokenReceived"];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.delegate verify];
        XCTAssertEqual(_authentication.state, XIAuthenticationStateError);
        [self.expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testInvalidResponseToTokenWithUsernameRequestExpectTokenReceived {
    [self testRequestTokenWithUsernameExpectPostToLoginUrl];
    NSError *error = [NSError errorWithDomain:@"dsgdfksghdfkj" code:300 userInfo:nil];
    
    [[self.resolveUserCall reject] requestUserWithAccountId:[OCMArg any] idmUserId:[OCMArg any]];
    [[self.delegate expect] authentication:[OCMArg any] didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *err = (NSError *)obj;
        return error.code == err.code;
    }]];
    [(id<XICOAuthenticationCallDelegate>)_authentication authenticationCall:(id<XICOAuthenticationCall>)self.authenticationCall didFailWithError:error];
    [self.resolveUserCall verify];
    
    XCTAssertEqual(_authentication.state, XIAuthenticationStateError);
    
    self.expectation = [self expectationWithDescription:@"testInvalidResponseToTokenWithUsernameRequestExpectTokenReceived"];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.delegate verify];
        [self.expectation fulfill];
        XCTAssertEqual(_authentication.state, XIAuthenticationStateError);
    });
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testValidResponseToTokenWithUsernameRequestExpectTokenReceivedThanCanceled {
    [self testInvalidResponseToTokenWithUsernameRequestExpectTokenReceived];
    
    [[self.authenticationCall expect] cancel];
    [[self.resolveUserCall expect] cancel];
    [_authentication cancel];
    [self.authenticationCall verify];
    [self.resolveUserCall verify];
    XCTAssertEqual(_authentication.state, XIAuthenticationStateCanceled);
}

- (void)testValidResponseToTokenWithUsernameRequestExpectTokenReceivedThanEndUserReceivedFailed {
    [self testValidResponseToTokenWithUsernameRequestExpectTokenReceived];
    
    NSError *error = [NSError errorWithDomain:@"dsgdfksghdfkj" code:300 userInfo:nil];
    
    [[self.delegate expect] authentication:[OCMArg any] didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *err = (NSError *)obj;
        return error.code == err.code;
    }]];
    
    
    [(id<XICOResolveUserCallDelegate>)_authentication resolveUserCall:(id<XICOResolveUserCall>)self.resolveUserCall didFailWithError:error];
    XCTAssertEqual(_authentication.state, XIAuthenticationStateError);
    self.expectation = [self expectationWithDescription:@"testValidResponseToTokenWithUsernameRequestExpectTokenReceivedThanEndUserReceived"];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.delegate verify];
        XCTAssertEqual(_authentication.state, XIAuthenticationStateError);
        [self.expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testValidResponseToTokenWithUsernameRequestExpectTokenReceivedThanEndUserReceive {
    [self testValidResponseToTokenWithUsernameRequestExpectTokenReceived];
    
    XICOBlueprintUser *user = [[XICOBlueprintUser alloc] initWithUserType:XICOBlueprintUserTypeEndUser Dictionary:@{}];
    
    [[self.delegate expect] authentication:[OCMArg any] didCreateSession:[OCMArg any]];
    [[[(OCMockObject *)self.servicesConfig stub] andReturn:nil] sdkConfig];
    
    
    [(id<XICOResolveUserCallDelegate>)_authentication resolveUserCall:(id<XICOResolveUserCall>)self.resolveUserCall didReceiveUser:user];
    XCTAssertEqual(_authentication.state, XIAuthenticationStateEnded);
    self.expectation = [self expectationWithDescription:@"testValidResponseToTokenWithUsernameRequestExpectTokenReceivedThanEndUserReceived"];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.delegate verify];
        XCTAssertEqual(_authentication.state, XIAuthenticationStateEnded);
        [self.expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end

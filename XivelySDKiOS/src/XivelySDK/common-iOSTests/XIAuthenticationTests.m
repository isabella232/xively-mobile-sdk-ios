//
//  XIOauthAccessRequest.m
//  common-iOS
//
//  Created by vfabian on 15/05/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIAuthentication.h"
#import "XIAccess.h"

@interface XIAuthentication (UnitTest)
-(instancetype) initWithAuthenticating: (id<XICOAuthenticating>) authenticating;
@end

@interface XIOauthAccessRequestTests : XCTestCase

@property(nonatomic, strong)NSString *providerId;
@property(nonatomic, strong)NSString *accountId;

@property(nonatomic, assign)BOOL presentUrlCalledBack;
@property(nonatomic, strong)NSURL *presentUrlUrl;

@property(nonatomic, strong)OCMockObject *delegate;

@end

@implementation XIOauthAccessRequestTests

@synthesize providerId;
@synthesize accountId;

@synthesize presentUrlCalledBack;
@synthesize presentUrlUrl;

- (void)setUp {
    [super setUp];
    self.providerId = @"vfberghfkgfjshgfkdsjgshkjgshgk";
    self.accountId = @"dsljfhdsflksdhfresklgfhreskljgregkljhr";
    self.delegate = [OCMockObject mockForProtocol:@protocol(XIAuthenticationDelegate)];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIAuthenticationCreation {
    XIAuthentication *request = [[XIAuthentication alloc] init];
    XCTAssert(request, @"Request creation failed");
}

- (void)testXIAuthenticationCreationWithInternal {
    id<XICOAuthenticating> authentication = OCMStrictProtocolMock(@protocol(XICOAuthenticating));
    XIAuthentication* request = [[XIAuthentication alloc] initWithAuthenticating: authentication];
    XCTAssert(request, @"Request creation failed");
}

- (void)testXIAuthenticationProxing {
    
    OCMockObject *mockObject = [OCMockObject mockForClass:[XICOAuthentication class]];
    XIAuthentication *request = [[XIAuthentication alloc] initWithAuthenticating:(XICOAuthentication*)mockObject];
    
    [(XICOAuthentication*)[[mockObject expect] andReturnValue:OCMOCK_VALUE(XIAuthenticationStateEnded)] state];
    XCTAssertEqual(XIAuthenticationStateEnded, request.state, @"Invalid state getting");
    [mockObject verify];
    
    [[[mockObject expect] andReturn:self.delegate] delegate];
    XCTAssertEqual(self.delegate, request.delegate, @"Invalid delegate getting");
    [mockObject verify];
    
    [[mockObject expect] setDelegate:(id<NSFileManagerDelegate>)self.delegate];
    request.delegate = (id<XIAuthenticationDelegate>)self.delegate;
    [mockObject verify];
    
    NSError *error = [NSError errorWithDomain:@"fdsgs" code:876 userInfo:nil];
    [[[mockObject expect] andReturn:error] error];
    XCTAssertEqual(error, request.error, @"Invalid error getting");
    [mockObject verify];
    
    [[mockObject expect] cancel];
    [request cancel];
    [mockObject verify];
}

- (void)testXIAuthenticationInternalCreation {
    XIAuthentication *request = [XIAuthentication alloc];
    XICOAuthentication* auth = [[XICOAuthentication alloc] initWithLogger: nil
                                                         restCallProvider: nil
                                                           servicesConfig: nil
                                                                    proxy: request
                                                                   access: nil
                                                       authenticationCall: nil
                                                           resolveUserCall: nil];
    XCTAssert(auth, @"Request internal creation failed");
    XCTAssertEqual(auth.state, XIAuthenticationStateIdle, @"Invalid start state");
}

@end

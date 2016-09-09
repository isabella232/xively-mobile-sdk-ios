//
//  XIDeviceInfoE2ETest.m
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIEndUserInfo.h"

#import "E2ETestCase.h"
#import "XISessionServices+EndUserHandler.h"
#import "XITestConfig.h"

@interface XIEndUserE2ETests : E2ETestCase <XIEndUserHandlerDelegate>
@property(nonatomic, strong) XIEndUserInfo* endUserInfo;
@property(nonatomic, weak) XCTestExpectation* receiveEndUserInfo;

@end

@implementation XIEndUserE2ETests
@synthesize endUserInfo = _endUserInfo;
@synthesize receiveEndUserInfo = _receiveEndUserInfo;


- (void) testASingleGetEndUserRequest {
    self.session = [self createEndUserSession];
    id<XIEndUserHandler> endUserHandler = [[self.session services] endUserHandler];
    id delegate = OCMStrictProtocolMock(@protocol(XIEndUserHandlerDelegate));
    [endUserHandler setDelegate:delegate];
    
    XCTestExpectation* receiveEndUserInfo = [self expectationWithDescription: @"didReceiveEndUserInfo"];
    OCMExpect([delegate endUserHandler: OCMOCK_ANY didReceiveEndUserInfo: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [receiveEndUserInfo fulfill];
    });
    
    [endUserHandler requestEndUser:endUserId];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    OCMVerifyAll(delegate);
}

- (void) testASinglePutEndUserRequest {
    self.session = [self createEndUserSession];
    id<XIEndUserHandler> endUserHandler = [[self.session services] endUserHandler];
    [endUserHandler setDelegate:self];
    
    self.receiveEndUserInfo = [self expectationWithDescription: @"didReceiveEndUserInfo after get"];
    
    [endUserHandler requestEndUser:endUserId];
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    XCTAssert(self.endUserInfo);
    
    XIEndUserInfo* endUserInfo = self.endUserInfo;
    self.endUserInfo = nil;
    long v = [endUserInfo.address integerValue];
    endUserInfo.address = [NSString stringWithFormat:@"%ld", (v + 1)];
    
    self.receiveEndUserInfo = [self expectationWithDescription: @"didReceiveEndUserInfo after put"];
    endUserHandler = [[self.session services] endUserHandler];
    [endUserHandler setDelegate:self];
    [endUserHandler putEndUser:endUserInfo];
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    XCTAssert(self.endUserInfo);
    XCTAssertEqual(self.endUserInfo.address, endUserInfo.address);
}

- (void)endUserHandler:(id<XIEndUserHandler>)endUserHandler didReceiveEndUserInfo:(XIEndUserInfo *)endUserInfo {
    self.endUserInfo = endUserInfo;
    [self.receiveEndUserInfo fulfill];
}

- (void)endUserHandler:(id<XIEndUserHandler>)endUserHandler didFailWithError:(NSError *)error {
    self.endUserInfo = nil;
    [self.receiveEndUserInfo fulfill];
}


@end

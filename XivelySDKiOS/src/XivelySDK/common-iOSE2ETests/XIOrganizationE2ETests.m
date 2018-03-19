//
//  XIOrganizationE2ETests.m
//  common-iOS
//
//  Created by tkorodi on 19/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIOrganizationInfo.h"

#import "E2ETestCase.h"
#import "XISessionServices+OrganizationHandler.h"
#import "XITestConfig.h"

@interface XIOrganizationInfoE2ETests : E2ETestCase
@property(nonatomic, strong) XIOrganizationInfo* organizationInfo;
@property(nonatomic, weak) XCTestExpectation* receiveOrganizationInfo;

@end

@implementation XIOrganizationInfoE2ETests
@synthesize organizationInfo = _organizationInfo;
@synthesize receiveOrganizationInfo = _receiveOrganizationInfo;


- (void) testASingleGetOrganizationRequest {
    self.session = [self createEndUserSession];
    id<XIOrganizationHandler> organizationHandler = [[self.session services] organizationHandler];
    id delegate = OCMStrictProtocolMock(@protocol(XIOrganizationHandlerDelegate));
    [organizationHandler setDelegate:delegate];
    
    XCTestExpectation* receiveDeviceInfo = [self expectationWithDescription: @"didReceiveOrganizationInfo"];
    OCMExpect([delegate organizationHandler: OCMOCK_ANY didReceiveOrganizationInfo: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [receiveDeviceInfo fulfill];
    });
    
    [organizationHandler requestOrganization:organizationId];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    OCMVerifyAll(delegate);
}

-(void) testAccountUserOrganizationInfoListRequestList {
    self.session = [self createEndUserSession];
    id<XIOrganizationHandler> organizationHandler = [[self.session services] organizationHandler];
    id delegate = OCMStrictProtocolMock(@protocol(XIOrganizationHandlerDelegate));
    [organizationHandler setDelegate:delegate];
    
    XCTestExpectation* receiveDeviceInfo = [self expectationWithDescription: @"didReceiveOrganizationInfoList"];
    OCMExpect([delegate organizationHandler: OCMOCK_ANY didReceiveList: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [receiveDeviceInfo fulfill];
    });
    
    [organizationHandler listOrganizations];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    OCMVerifyAll(delegate);
}


@end
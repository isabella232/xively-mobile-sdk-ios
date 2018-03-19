//
//  XIDeviceInfoListE2ETests.m
//  common-iOS
//
//  Created by gszajko on 09/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "E2ETestCase.h"
#import "XISessionServices+DeviceInfo.h"

@interface XIDeviceInfoListE2ETests : E2ETestCase
@end

@implementation XIDeviceInfoListE2ETests

-(void) testEndUserDeviceInfoListRequestList {
    self.session = [self createEndUserSession];
    id<XIDeviceInfoList> deviceInfos = [[self.session services] deviceInfoList];
    id delegate = OCMStrictProtocolMock(@protocol(XIDeviceInfoListDelegate));
    [deviceInfos setDelegate: delegate];
    
    XCTestExpectation* receiveList = [self expectationWithDescription: @"didReceiveList"];
    OCMExpect([delegate deviceInfoList: OCMOCK_ANY didReceiveList: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [receiveList fulfill];
    });
    
    [deviceInfos requestList];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    OCMVerifyAll(delegate);
}

-(void) testAccountUserDeviceInfoListRequestList {
    self.session = [self createAccountUserSession];
    id<XIDeviceInfoList> deviceInfos = [[self.session services] deviceInfoList];
    id delegate = OCMStrictProtocolMock(@protocol(XIDeviceInfoListDelegate));
    [deviceInfos setDelegate: delegate];
    
    XCTestExpectation* receiveList = [self expectationWithDescription: @"didReceiveList"];
    OCMExpect([delegate deviceInfoList: OCMOCK_ANY didReceiveList: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [receiveList fulfill];
    });
    
    [deviceInfos requestList];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    OCMVerifyAll(delegate);
}

@end

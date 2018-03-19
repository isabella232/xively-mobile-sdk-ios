//
//  XIAccessTest.m
//  common-iOS
//
//  Created by vfabian on 14/01/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XIAccess.h"
#import <OCMock/OCMock.h>

@interface XIAccessTest : XCTestCase

@end

@implementation XIAccessTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAccessCreation {
    NSString *password = @"password";
    NSString *deviceId = @"device id";
    NSString *accountId = @"gfd-hg-dfhf-h-hfd-h-fhdf-h-fh-gfnj-fj-ytjm-yj-yj-tf";
    NSString *jwt = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6ImY3NDA0MGQyLWE1ODUtNDVmMC1hZWEzLTY1YjFjOTYyNzIxMCIsInVzZXJJZCI6IjAzOTA1YTBmLTAwNTAtNGU4NS05NjVlLWJmOWJjYWY0ODA4MyIsImV4cGlyZXMiOjE0MzU4Mzg4MzA0NjMsImNlcnQiOiI5ZWMyZDQ2My1jYTY3LTRkZTctYjQ0Mi03YTk4Y2RiMjIwYTAiLCJyZW5ld2FsS2V5IjoidHMzR3d2VkNLZ1BYQXJlOEx2VGVDUT09IiwiYWNjb3VudElkIjoiNTgzOWJkNWUtZGQ1Ni00NDgzLWJlMTAtN2UwMTJlMDk2ZWE3In0.DfPCQUBMbh8yhVjG6F0njqb45WdcUKA-ysHkRPwHCeA";
    
    XIAccess *access = [[XIAccess alloc] init];
    XCTAssertEqual(XIAccessBlueprintUserTypeUndefined, access.blueprintUserType);
    
    XCTAssert(access);
    access.accountId = accountId;
    access.mqttPassword = password;
    access.mqttDeviceId = deviceId;
    access.blueprintUserType = XIAccessBlueprintUserTypeEndUser;
    access.blueprintUserId = @"sdfgsdfhfdshsdfhfd";
    access.jwt = jwt;
    
    XCTAssertEqual(XIAccessBlueprintUserTypeEndUser, access.blueprintUserType);
    XCTAssert( [access.blueprintUserId isEqualToString:access.mqttUsername], @"Failed to set username");
    XCTAssert( [password isEqualToString:access.mqttPassword], @"Failed to set password");
    XCTAssert( [deviceId isEqualToString:access.mqttDeviceId], @"Failed to set deviceId");
    XCTAssert( [accountId isEqualToString:access.accountId], @"Failed to set accountId");
    XCTAssert( [jwt isEqualToString:access.jwt], @"Failed to set jwt");
    XCTAssert([@"03905a0f-0050-4e85-965e-bf9bcaf48083" isEqualToString:access.idmUserId], @"IdM user mismatching");
    
}





@end

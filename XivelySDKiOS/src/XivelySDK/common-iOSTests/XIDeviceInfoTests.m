//
//  XIDeviceInfoTests.m
//  common-iOS
//
//  Created by vfabian on 25/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "XIDeviceInfo.h"
#import "XIDeviceInfo+InitWithDictionary.h"

@interface XIDeviceInfoTests : XCTestCase

@end

@implementation XIDeviceInfoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIDeviceInfoCreationWithValidData {
    NSString *deviceId = @"09568054-5b66-4bc7-9b5b-7a189016ef53";
    NSString *serialNumber = @"2d7d3405-49b2-44e5-8f2b-eca0c32aebe0";
    NSString *provisioningState = @"defined";
    NSString *deviceVersion = @"4l53kj6hkl5j6543hk635hjk63456hkl3456j45h6lk45j65kl6hj";
    NSString *deviceLocation = @"lk45654kjhl6g4k36345645";
    NSString *deviceName = @"09568054-5b66-4bc7-9b5b-7a189016ef53";
    NSString *purchaseDate = @"2015-04-24T11:55:28.000Z";
    
    NSDictionary *dict = @{
        @"id": deviceId,
        @"created": @"2015-04-24T11:55:28.000Z",
        @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
        @"lastModified": @"2015-04-24T11:55:28.000Z",
        @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
        @"version": @"WV",
        @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
        @"deviceTemplateId": @"5516cc02-b27f-4ad2-9b8c-b1489b23aadc",
        @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
        @"serialNumber": serialNumber,
        @"provisioningState": provisioningState,
        @"deviceVersion": deviceVersion,
        @"location": deviceLocation,
        @"name": deviceName,
        @"purchaseDate": purchaseDate,
        @"channels": @[
                     @{
                         @"channelTemplateId": @"607445df-aaf1-4bf0-9f00-5b2a4a1fac8c",
                         @"channelTemplateName": @"ad-hoc-topic-persistent",
                         @"persistenceType": @"timeSeries",
                         @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-persistent"
                     },
                     @{
                         @"channelTemplateId": @"ea45c846-5481-4b4e-a472-f72878a85e1c",
                         @"channelTemplateName": @"ad-hoc-topic-simple",
                         @"persistenceType": @"simple",
                         @"channel": @"xi/blue/v1/5839bd5e-dd56-4483-be10-7e012e096ea7/d/09568054-5b66-4bc7-9b5b-7a189016ef53/ad-hoc-topic-simple"
                     }
                     ]
        };
    
    XIDeviceInfo *deviceInfo = [[XIDeviceInfo alloc] initWithDictionary:dict];
    XCTAssert(deviceInfo, @"Device info creation failed");
    
    XCTAssert([deviceId isEqualToString:deviceInfo.deviceId], @"deviceId setting invalid");
    XCTAssert([serialNumber isEqualToString:deviceInfo.serialNumber], @"serialNumber setting invalid");
    XCTAssertEqual(deviceInfo.provisioningState, XIDeviceInfoProvisioningStateDefined, @"provisioningState setting invalid");
    XCTAssert([deviceVersion isEqualToString:deviceInfo.deviceVersion], @"deviceVersion setting invalid");
    XCTAssert([deviceName isEqualToString:deviceInfo.deviceName], @"deviceLocation setting invalid");
    XCTAssert(deviceInfo.purchaseDate, @"purchaseDate setting invalid");
    
    XCTAssertEqual(deviceInfo.deviceChannels.count, 2, @"deviceChannels setting invalid");
}

- (void)testXIDeviceInfoCreationWithNulls {
    NSNull *deviceId = [NSNull null];
    NSNull *serialNumber = [NSNull null];
    NSNull *provisioningState = [NSNull null];
    NSNull *deviceVersion = [NSNull null];
    NSNull *deviceLocation = [NSNull null];
    NSNull *deviceName = [NSNull null];
    NSNull *purchaseDate = [NSNull null];
    
    NSDictionary *dict = @{
                           @"id": deviceId,
                           @"created": @"2015-04-24T11:55:28.000Z",
                           @"createdById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                           @"lastModified": @"2015-04-24T11:55:28.000Z",
                           @"lastModifiedById": @"xi/no-domain/00000000-0000-0000-0000-000000000000",
                           @"version": @"WV",
                           @"accountId": @"5839bd5e-dd56-4483-be10-7e012e096ea7",
                           @"deviceTemplateId": @"5516cc02-b27f-4ad2-9b8c-b1489b23aadc",
                           @"organizationId": @"72ebdefe-3b11-496a-84c6-19905c8136a6",
                           @"serialNumber": serialNumber,
                           @"provisioningState": provisioningState,
                           @"deviceVersion": deviceVersion,
                           @"location": deviceLocation,
                           @"name": deviceName,
                           @"purchaseDate": purchaseDate,
                           @"channels": [NSNull null]
                           };
    
    XIDeviceInfo *deviceInfo = [[XIDeviceInfo alloc] initWithDictionary:dict];
    XCTAssert(deviceInfo, @"Device info creation failed");
    
    XCTAssertNil(deviceInfo.deviceId, @"deviceId setting invalid");
    XCTAssertNil(deviceInfo.serialNumber, @"serialNumber setting invalid");
    XCTAssertEqual(deviceInfo.provisioningState, XIDeviceInfoProvisioningStateDefined, @"provisioningState setting invalid");
    XCTAssertNil(deviceInfo.deviceVersion, @"deviceVersion setting invalid");
    XCTAssertNil(deviceInfo.deviceName, @"deviceLocation setting invalid");
    XCTAssertNil(deviceInfo.purchaseDate, @"purchaseDate setting invalid");
    
    XCTAssertEqual(deviceInfo.deviceChannels.count, 0, @"deviceChannels setting invalid");
}

- (void)testXIDeviceInfoCreationWithActivatedDevice {
    NSString *provisioningState = @"activated";
    
    NSDictionary *dict = @{
                           @"provisioningState": provisioningState,
                           };
    
    XIDeviceInfo *deviceInfo = [[XIDeviceInfo alloc] initWithDictionary:dict];
    XCTAssert(deviceInfo, @"Device info creation failed");
    
    XCTAssertEqual(deviceInfo.provisioningState, XIDeviceInfoProvisioningStateActivated, @"provisioningState setting invalid");
}

- (void)testXIDeviceInfoCreationWithAssociatedDevice {
    NSString *provisioningState = @"associated";
    
    NSDictionary *dict = @{
                           @"provisioningState": provisioningState,
                           };
    
    XIDeviceInfo *deviceInfo = [[XIDeviceInfo alloc] initWithDictionary:dict];
    XCTAssert(deviceInfo, @"Device info creation failed");
    
    XCTAssertEqual(deviceInfo.provisioningState, XIDeviceInfoProvisioningStateAssociated, @"provisioningState setting invalid");
}

- (void)testXIDeviceInfoCreationWithReservedDevice {
    NSString *provisioningState = @"reserved";
    
    NSDictionary *dict = @{
                           @"provisioningState": provisioningState,
                           };
    
    XIDeviceInfo *deviceInfo = [[XIDeviceInfo alloc] initWithDictionary:dict];
    XCTAssert(deviceInfo, @"Device info creation failed");
    
    XCTAssertEqual(deviceInfo.provisioningState, XIDeviceInfoProvisioningStateReserved, @"provisioningState setting invalid");
}


@end

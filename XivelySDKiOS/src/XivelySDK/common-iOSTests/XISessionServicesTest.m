//
//  XISessionServicesTest.m
//  common-iOS
//
//  Created by vfabian on 15/01/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "XIAccess.h"
#import "XISessionInternal.h"
#import "XISessionServices.h"
#import "XISessionServices+Init.h"
#import "XISessionServicesInternal.h"
#import "XIServicesConfig.h"
// TBD #import "XISessionServices+DeviceAssociation.h"
#import "XISessionServices+Messaging.h"
#import "XISessionServices+DeviceInfo.h"
#import "XISessionServices+TimeSeries.h"

@interface XISessionServicesTest : XCTestCase

@property(nonatomic, strong)XIAccess *access;
@property(nonatomic, strong)XISessionInternal *session;
@property(nonatomic, strong)XIServicesConfig *servicesConfig;

@end

@implementation XISessionServicesTest


- (void)setUp {
    [super setUp];
    self.servicesConfig = [[XIServicesConfig alloc] initWithSdkConfig: [XISdkConfig config]];
    NSString *password = @"password";
    NSString *deviceId = @"device id";
    NSString *accountId = @"gfd-hg-dfhf-h-hfd-h-fhdf-h-fh-gfnj-fj-ytjm-yj-yj-tf";
    NSString *jwt = @"k45l6g54kl6g346ljh54g65j4h6g435jkhg6jh5g6j";
    
    self.access = [[XIAccess alloc] init];
    XCTAssert(access);
    self.access.accountId = accountId;
    self.access.mqttPassword = password;
    self.access.mqttDeviceId = deviceId;
    self.access.jwt = jwt;

    self.session = [[XISessionInternal alloc] initWithLogger:nil
                                            restCallProvider:(id<XIRESTCallProvider>)[NSObject new]
                                              servicesConfig:self.servicesConfig
                                                      access:self.access];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXISessionServices {
    OCMockObject *mockInternal = [OCMockObject mockForClass:[XISessionServicesInternal class]];
    XISessionServices * services = [[XISessionServices alloc] initWithSessionServicesInternal:(XISessionServicesInternal *)mockInternal];
    XCTAssertNotNil(services, @"Creating XISessionServices failed");
}

- (void)testXISessionServicesProxing {
    OCMockObject *mockInternal = [OCMockObject mockForClass:[XISessionServicesInternal class]];
    XISessionServices *services = [[XISessionServices alloc] initWithSessionServicesInternal:(XISessionServicesInternal *)mockInternal];
    
    NSObject *object = [NSObject new];
    
    /* TBD [[[mockInternal expect] andReturn:object] deviceAssociation];
    XCTAssertEqual(services.deviceAssociation, object, @"Device association provision fails");
    [mockInternal verify];*/
    
    [[[mockInternal expect] andReturn:object] messagingCreator];
    XCTAssertEqual(services.messagingCreator, object, @"Messaging provision fails");
    [mockInternal verify];
    
    [[[mockInternal expect] andReturn:object] deviceInfoList];
    XCTAssertEqual(services.deviceInfoList, object, @"Device info provision fails");
    [mockInternal verify];
    
    [[[mockInternal expect] andReturn:object] timeSeries];
    XCTAssertEqual(services.timeSeries, object, @"Time series provision fails");
    [mockInternal verify];
}


- (void)testXISessionServicesInternalCreation {
    XISessionServicesInternal *services = [[XISessionServicesInternal alloc] initWithSession:self.session];
    XCTAssertNotNil(services, @"Creating XISessionServicesInternal failed");
}

- (void)testXISessionServicesInternalStaticCreation {
    XISessionServicesInternal *services = [XISessionServicesInternal servicesWithSession:self.session];
    XCTAssertNotNil(services, @"Creating XISessionServicesInternal failed");
}

/* TBD - (void)testXISessionServicesInternalDeviceAssociationCreation {
    XISessionServicesInternal *services = [XISessionServicesInternal servicesWithSession:self.session];
    XCTAssert([services deviceAssociation], @"Device Association failed");
} */

- (void)testXISessionServicesInternalMessagingCreation {
    XISessionServicesInternal *services = [XISessionServicesInternal servicesWithSession:self.session];
    XCTAssert([services messagingCreator], @"Messaging failed");
}

- (void)testXISessionServicesInternalDeviceInfoCreation {
    XISessionServicesInternal *services = [XISessionServicesInternal servicesWithSession:self.session];
    XCTAssert([services deviceInfoList], @"Messaging failed");
}

- (void)testXISessionServicesInternalTimeSeriesCreation {
    XISessionServicesInternal *services = [XISessionServicesInternal servicesWithSession:self.session];
    XCTAssert([services timeSeries], @"Time series failed");
}

- (id<XIRESTCallProvider>)restCallProvider {
    return nil;
}

- (void)close {
    
}

@end

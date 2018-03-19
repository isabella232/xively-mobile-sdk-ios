//
//  XIDeviceInfoE2ETest.m
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "XIDeviceInfo.h"

#import "E2ETestCase.h"
#import "XISessionServices+DeviceInfo.h"
#import "XITestConfig.h"

@interface XIDeviceInfoE2ETests : E2ETestCase <XIDeviceHandlerDelegate>
@property(nonatomic, strong) XIDeviceInfo* deviceInfo;
@property(nonatomic, weak) XCTestExpectation* receiveDeviceInfo;

@end

@implementation XIDeviceInfoE2ETests
    @synthesize deviceInfo = _deviceInfo;
    @synthesize receiveDeviceInfo = _receiveDeviceInfo;


- (void) testASingleGetDeviceRequest {
    self.session = [self createEndUserSession];
    id<XIDeviceHandler> deviceHandler = [[self.session services] deviceHandler];
    id delegate = OCMStrictProtocolMock(@protocol(XIDeviceHandlerDelegate));
    [deviceHandler setDelegate:delegate];
    
    XCTestExpectation* receiveDeviceInfo = [self expectationWithDescription: @"didReceiveDeviceInfo"];
    OCMExpect([delegate deviceHandler: OCMOCK_ANY didReceiveDeviceInfo: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [receiveDeviceInfo fulfill];
    });
    
    [deviceHandler requestDevice:deviceId];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    OCMVerifyAll(delegate);
}

- (void) testASinglePutDeviceRequest {
    self.session = [self createEndUserSession];
    id<XIDeviceHandler> deviceHandler = [[self.session services] deviceHandler];
    [deviceHandler setDelegate:self];
    
    self.receiveDeviceInfo = [self expectationWithDescription: @"didReceiveDeviceInfo after get"];
    
    [deviceHandler requestDevice:deviceId];
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    XCTAssert(self.deviceInfo);
    
    XIDeviceInfo* deviceInfo = self.deviceInfo;
    self.deviceInfo = nil;
    long v = [deviceInfo.serialNumber integerValue];
    deviceInfo.serialNumber = [NSString stringWithFormat:@"%ld", (v + 1)];
	
	NSDictionary* dictionary = [ NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:5.444] forKey:@"latitude"];
	[deviceInfo setFieldsToUpdate:dictionary];
    
    self.receiveDeviceInfo = [self expectationWithDescription: @"didReceiveDeviceInfo after put"];
    deviceHandler = [[self.session services] deviceHandler];
    [deviceHandler setDelegate:self];
    [deviceHandler putDevice:deviceInfo];
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
    XCTAssert(self.deviceInfo);
    XCTAssertEqual(self.deviceInfo.serialNumber, deviceInfo.serialNumber);
    XCTAssertEqualObjects(self.deviceInfo.customFields[@"latitude"], [NSNumber numberWithDouble:5.444]);
}

- (void)deviceHandler:(id<XIDeviceHandler>)deviceHandler didReceiveDeviceInfo:(XIDeviceInfo *)deviceInfo {
    self.deviceInfo = deviceInfo;
    [self.receiveDeviceInfo fulfill];
}

- (void)deviceHandler:(id<XIDeviceHandler>)deviceHandler didFailWithError:(NSError *)error {
    self.deviceInfo = nil;
    [self.receiveDeviceInfo fulfill];
}


@end

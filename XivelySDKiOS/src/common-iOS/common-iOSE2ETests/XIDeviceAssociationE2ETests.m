//
//  XIDeviceAssociationE2ETests.m
//  common-iOS
//
//  Created by gszajko on 09/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "E2ETestCase.h"
#import "XISessionServices+DeviceAssociation.h"

@interface XIDeviceAssociationE2ETests : E2ETestCase

@end

@implementation XIDeviceAssociationE2ETests
-(void) testDeviceAssociation {
    self.session = [self createEndUserSession];
    id<XIDeviceAssociation> deviceAssociation = [[self.session services] deviceAssociation];
    id delegate = OCMStrictProtocolMock(@protocol(XIDeviceAssociationDelegate));
    [deviceAssociation setDelegate: delegate];
    
    XCTestExpectation* failed = [self expectationWithDescription: @"didFailWithError"];
    OCMExpect([delegate deviceAssociation: OCMOCK_ANY didFailWithError: OCMOCK_ANY]).andDo(^(NSInvocation* i){
        [failed fulfill];
    });
    
    [deviceAssociation associateDeviceWithAssociationCode: @"not-existing-device-association-code"];
    
    [self waitForExpectationsWithTimeout: 20.f handler: nil];
}
@end

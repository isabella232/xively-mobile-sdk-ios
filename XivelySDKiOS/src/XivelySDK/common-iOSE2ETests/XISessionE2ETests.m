//
//  XISessionE2ETests.m
//  common-iOS
//
//  Created by gszajko on 08/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "E2ETestCase.h"
#import "XISessionServices.h"
#import "XISessionServices+TimeSeries.h"
#import "XISessionServices+DeviceInfo.h"
#import "XISessionServices+Messaging.h"
// TBD #import "XISessionServices+DeviceAssociation.h"
#import "XITimeSeries.h"

@interface XISessionE2ETests : E2ETestCase
@end

@implementation XISessionE2ETests

- (void)testCreateSession {
    self.session = [self createEndUserSession];
    XCTAssertNotNil(self.session);
}

- (void)testCreateTimeSeriesServices {
    self.session = [self createEndUserSession];
    XCTAssertNotNil(self.session);
    XCTAssertNotNil([[self.session services] timeSeries]);
}

- (void)testCreateDeviceInfoServices {
    self.session = [self createEndUserSession];
    XCTAssertNotNil(self.session);
    XCTAssertNotNil([[self.session services] deviceInfoList]);
}

/* TBD - (void)testCreateDeviceAssociationServices {
    self.session = [self createEndUserSession];
    XCTAssertNotNil(self.session);
    XCTAssertNotNil([[self.session services] deviceAssociation]);
} */

- (void)testEndUserCreateMessagingServicesWithCleanSession {
    self.session = [self createEndUserSession];
    XCTAssertNotNil(self.session);

    id dccDelegate = OCMStrictProtocolMock(@protocol(XIMessagingCreatorDelegate));
    id<XIMessagingCreator> creator = [[self.session services] messagingCreator];
    [creator setDelegate: dccDelegate];
    
    XCTestExpectation* created = [self expectationWithDescription: @"didCreateMessaging"];
    OCMExpect([dccDelegate messagingCreator: OCMOCK_ANY didCreateMessaging: OCMOCK_ANY]).andDo(^(NSInvocation* i) {
        [created fulfill];
    });
    
    [creator createMessaging];
    
    [self waitForExpectationsWithTimeout: 30.f handler: nil];
    [self.session close];
    OCMVerifyAll(dccDelegate);
}

- (void)testAccountUserCreateDeviceControlServicesWithCleanSession {
    self.session = [self createAccountUserSession];
    XCTAssertNotNil(self.session);
    
    id dccDelegate = OCMStrictProtocolMock(@protocol(XIMessagingCreatorDelegate));
    id<XIMessagingCreator> creator = [[self.session services] messagingCreator];
    [creator setDelegate: dccDelegate];
    
    XCTestExpectation* created = [self expectationWithDescription: @"didCreateMessaging"];
    OCMExpect([dccDelegate messagingCreator: OCMOCK_ANY didCreateMessaging: OCMOCK_ANY]).andDo(^(NSInvocation* i) {
        [created fulfill];
    });
    
    [creator createMessaging];
    
    [self waitForExpectationsWithTimeout: 30.f handler: nil];
    
    [self.session close];
    OCMVerifyAll(dccDelegate);
}

/*
// @Deprecated
- (void)testEndUserCreateMessagingServicesWithUnleanSession {
    self.session = [self createEndUserSession];
    XCTAssertNotNil(self.session);
    
    id dccDelegate = OCMStrictProtocolMock(@protocol(XIMessagingCreatorDelegate));
    id<XIMessagingCreator> creator = [[self.session services] messagingCreator];
    [creator setDelegate: dccDelegate];
    
    XCTestExpectation* created = [self expectationWithDescription: @"didCreateMessaging"];
    OCMExpect([dccDelegate messagingCreator: OCMOCK_ANY didCreateMessaging: OCMOCK_ANY]).andDo(^(NSInvocation* i) {
        [created fulfill];
    });
    
    [creator createMessagingWithCleanSession:NO];
    
    [self waitForExpectationsWithTimeout: 30.f handler: nil];
    [self.session close];
    OCMVerifyAll(dccDelegate);
}

// @Deprecated
- (void)testAccountUserCreateDeviceControlServicesWithUnleanSession {
    self.session = [self createAccountUserSession];
    XCTAssertNotNil(self.session);
    
    id dccDelegate = OCMStrictProtocolMock(@protocol(XIMessagingCreatorDelegate));
    id<XIMessagingCreator> creator = [[self.session services] messagingCreator];
    [creator setDelegate: dccDelegate];
    
    XCTestExpectation* created = [self expectationWithDescription: @"didCreateMessaging"];
    OCMExpect([dccDelegate messagingCreator: OCMOCK_ANY didCreateMessaging: OCMOCK_ANY]).andDo(^(NSInvocation* i) {
        [created fulfill];
    });
    
    [creator createMessagingWithCleanSession:NO];
    
    [self waitForExpectationsWithTimeout: 30.f handler: nil];
    
    [self.session close];
    OCMVerifyAll(dccDelegate);
}
*/

@end

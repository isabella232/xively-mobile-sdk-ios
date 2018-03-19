//
//  XILastWillTests.m
//  common-iOS
//
//  Created by gszajko on 26/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XILastWill.h"

@interface XILastWillTests : XCTestCase

@end

@implementation XILastWillTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testConstructor {
    NSData* message = [@"data" dataUsingEncoding: NSUTF8StringEncoding];
    XILastWill* lastwill = [[XILastWill alloc] initWithChannel: @"topic"
                                                     message: message
                                                         qos: XIMessagingQoSAtMostOnce
                                                      retain: YES];
    
    XCTAssert([[lastwill channel] isEqualToString: @"topic"]);
    XCTAssert([[lastwill message] isEqualToData: message]);
    XCTAssert([lastwill qos] == XIMessagingQoSAtMostOnce);
    XCTAssert([lastwill retained]);
}

@end

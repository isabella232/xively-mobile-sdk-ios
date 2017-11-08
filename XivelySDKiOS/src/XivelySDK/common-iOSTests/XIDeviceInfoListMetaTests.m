//
//  XIDeviceInfoListMetaTests.m
//  common-iOS
//
//  Created by vfabian on 25/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "XIDIDeviceInfoListMeta.h"

@interface XIDeviceInfoListMetaTests : XCTestCase

@end

@implementation XIDeviceInfoListMetaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXIDeviceInfoListMetaFilledCreation {
    NSDictionary *dict = @{
        @"count": @(798),
        @"page": @(2),
        @"pageSize": @(100),
        @"sortOrder": @"asc"
        };
    
    XIDIDeviceInfoListMeta *meta = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:dict];
    
    XCTAssert(meta, @"meta creation failed");
    XCTAssertEqual(meta.count, 798, @"Invalid count");
    XCTAssertEqual(meta.page, 2, @"Invalid page");
    XCTAssertEqual(meta.pageSize, 100, @"Invalid pageSize");
    XCTAssert([meta.sortOrder isEqualToString:@"asc"], @"Invalid sortOrder");
    
}

- (void)testXIDeviceInfoListMetaEmptyCreation {
    NSDictionary *dict = @{
                           @"count": [NSNull null],
                           @"page": [NSNull null],
                           @"pageSize": [NSNull null],
                           @"sortOrder": [NSNull null]
                           };
    
    XIDIDeviceInfoListMeta *meta = [[XIDIDeviceInfoListMeta alloc] initWithDictionary:dict];
    
    XCTAssert(meta, @"meta creation failed");
    XCTAssertEqual(meta.count, 0, @"Invalid count");
    XCTAssertEqual(meta.page, 0, @"Invalid page");
    XCTAssertEqual(meta.pageSize, 0, @"Invalid pageSize");
    XCTAssertNil(meta.sortOrder, @"Invalid sortOrder");
}

@end

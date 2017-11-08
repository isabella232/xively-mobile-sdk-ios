//
//  XITSTimeSeriesMetaTests.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDateFormatter+XITimeSeries.h"
#import "XITSTimeSeriesMeta.h"

@interface XITSTimeSeriesMetaTests : XCTestCase

@end

@implementation XITSTimeSeriesMetaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXITSTimeSeriesMetaCreation {
    NSDateFormatter *dateFormatter = [NSDateFormatter timeSeriesDateFormatter];
    NSInteger timeSpent = 777;
    NSString *startString = @"2015-09-14T11:30:02Z";
    NSString *endString = @"2015-09-14T22:30:02Z";
    NSInteger count = 55;
    NSString *pagingToken = @"4kj5324jkh54g32jkh5234g5hjk432g5kj4325g324jk5g34jkh";
    NSDate *start = [dateFormatter dateFromString:startString];
    NSDate *end = [dateFormatter dateFromString:endString];
    
    XITSTimeSeriesMeta *meta = [[XITSTimeSeriesMeta alloc] initWithTimeSeries:timeSpent start:start end:end count:count pagingToken:pagingToken];
    XCTAssert(meta, @"Meta creation failed");
    XCTAssertEqual(timeSpent, meta.timeSpent, @"TimeSpent resolution failed");
    XCTAssertEqual(count, meta.count, @"Count resolution failed");
    XCTAssert([startString isEqualToString:[dateFormatter stringFromDate:meta.start]], @"Start resolution failed");
    XCTAssert([endString isEqualToString:[dateFormatter stringFromDate:meta.end]], @"End resolution failed");
    XCTAssert([pagingToken isEqualToString:meta.pagingToken], @"PagingToken resolution failed");
}

- (void)testXITSTimeSeriesMetaCreationByDictionary {
    NSDateFormatter *dateFormatter = [NSDateFormatter timeSeriesDateFormatter];
    NSInteger timeSpent = 777;
    NSString *startString = @"2015-09-14T11:30:02Z";
    NSString *endString = @"2015-09-14T22:30:02Z";
    NSInteger count = 55;
    NSString *pagingToken = @"4kj5324jkh54g32jkh5234g5hjk432g5kj4325g324jk5g34jkh";
    NSDictionary *dict = @{
                           @"timeSpent" : @(timeSpent),
                           @"start" : startString,
                           @"end" : endString,
                           @"count" : @(count),
                           @"pagingToken" : pagingToken
                           };
    
    XITSTimeSeriesMeta *meta = [[XITSTimeSeriesMeta alloc] initWithDictionary:dict];
    XCTAssert(meta, @"Meta creation failed");
    XCTAssertEqual(timeSpent, meta.timeSpent, @"TimeSpent resolution failed");
    XCTAssertEqual(count, meta.count, @"Count resolution failed");
    XCTAssert([startString isEqualToString:[dateFormatter stringFromDate:meta.start]], @"Start resolution failed");
    XCTAssert([endString isEqualToString:[dateFormatter stringFromDate:meta.end]], @"End resolution failed");
    XCTAssert([pagingToken isEqualToString:meta.pagingToken], @"PagingToken resolution failed");
}

@end

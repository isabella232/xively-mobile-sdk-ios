//
//  XITimeSeriesDateFormatter.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDateFormatter+XITimeSeries.h"

@interface XITimeSeriesDateFormatter : XCTestCase

@end

@implementation XITimeSeriesDateFormatter

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTimeSeriesDateFormatter {
    
    NSString *dateString1 = @"2015-09-14T11:30:02Z";
    NSString *dateString2 = @"2015-09-14T22:30:02Z";
    
    NSDateFormatter *dateFormatter = [NSDateFormatter timeSeriesDateFormatter];
    XCTAssert(dateFormatter, @"Time series date formatter creation failed");
    NSDate *date1 = [dateFormatter dateFromString:dateString1];
    NSDate *date2 = [dateFormatter dateFromString:dateString2];
    XCTAssert(date1, @"AM date transforming failed");
    XCTAssert(date2, @"AM date transforming failed");
    
    NSString *reFormattedString1 = [dateFormatter stringFromDate:date1];
    NSString *reFormattedString2 = [dateFormatter stringFromDate:date2];
    
    XCTAssert([dateString1 isEqualToString:reFormattedString1], @"Reformatting error");
    XCTAssert([dateString2 isEqualToString:reFormattedString2], @"Reformatting error");
}


@end

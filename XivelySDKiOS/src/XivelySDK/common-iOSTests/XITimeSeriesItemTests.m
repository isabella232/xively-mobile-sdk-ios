//
//  XITimeSeriesItemTests.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "XITimeSeriesItem.h"
#import "XITimeSeriesItem+Initializers.h"
#import "NSDateFormatter+XITimeSeries.h"

@interface XITimeSeriesItemTests : XCTestCase

@end

@implementation XITimeSeriesItemTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXITimeSeriesItemNormalCreation {
    NSDate *time = [NSDate date];
    NSString *category = @"43mh5g43kjh5g432jhk5g435jk35kj4hg";
    NSString *stringValue = @"34kjl5h432klj5h432k5lj43h5kl432h5lk3245h234klj5h34k5jlh";
    NSNumber *numericValue = @(12);
    
    XITimeSeriesItem *timeSeriesItem = [[XITimeSeriesItem alloc] initWithTime:time
                                                                     category:category
                                                                  stringValue:stringValue
                                        numericValue:numericValue];
    
    XCTAssert(timeSeriesItem, @"Item creation failed");
    XCTAssert([time isEqualToDate:timeSeriesItem.time], @"Time setting failed");
    XCTAssert([category isEqualToString:timeSeriesItem.category], @"Category setting failed");
    XCTAssert([stringValue isEqualToString:timeSeriesItem.stringValue], @"StringValue setting failed");
    XCTAssertEqual(numericValue, timeSeriesItem.numericValue, @"stringValue setting failed");
}

- (void)testXITimeSeriesItemCreationByDictionary {
    NSDate *time = [NSDate date];
    NSString *category = @"43mh5g43kjh5g432jhk5g435jk35kj4hg";
    NSString *stringValue = @"34kjl5h432klj5h432k5lj43h5kl432h5lk3245h234klj5h34k5jlh";
    NSNumber *numericValue = @(12);
    
    NSDictionary *dict = @{
                           @"time" : [[NSDateFormatter timeSeriesDateFormatter] stringFromDate:time],
                           @"category" : category,
                           @"stringValue" : stringValue,
                           @"numericValue" : numericValue
                           };
    
    XITimeSeriesItem *timeSeriesItem = [[XITimeSeriesItem alloc] initWithDictionary:dict];
    
    XCTAssert(timeSeriesItem, @"Item creation failed");
    XCTAssert([[[NSDateFormatter timeSeriesDateFormatter] stringFromDate:time] isEqualToString:[[NSDateFormatter timeSeriesDateFormatter] stringFromDate:timeSeriesItem.time]], @"Time setting failed");
    XCTAssert([category isEqualToString:timeSeriesItem.category], @"Category setting failed");
    XCTAssert([stringValue isEqualToString:timeSeriesItem.stringValue], @"StringValue setting failed");
    XCTAssertEqual(numericValue, timeSeriesItem.numericValue, @"stringValue setting failed");
}


@end

//
//  XITimeSeriesItem.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XITimeSeriesItem.h"
#import "NSDateFormatter+XITimeSeries.h"

@interface XITimeSeriesItem () {
    NSDate *_time;
    NSString *_category;
    NSString *_stringValue;
}

@end

@implementation XITimeSeriesItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSDateFormatter *dateFormatter = [NSDateFormatter timeSeriesDateFormatter];
    NSDate *date = dictionary[@"time"] ? [dateFormatter dateFromString:(NSString *)dictionary[@"time"]] : nil;
    NSString *category = dictionary[@"category"];
    NSString *stringValue = dictionary[@"stringValue"];
    NSNumber *numericValue = dictionary[@"numericValue"];
    
    return [self initWithTime:date category:category stringValue:stringValue numericValue:numericValue];
}

- (instancetype)initWithTime:(NSDate *)time category:(NSString *)category stringValue:(NSString *)stringValue numericValue:(NSNumber *)numericValue{
    assert(time);
    assert(category);
    
    self = [super init];
    if (self) {
        _time = time;
        _category = category;
        _stringValue = stringValue;
        _numericValue = numericValue;
    }
    return self;
}

@end

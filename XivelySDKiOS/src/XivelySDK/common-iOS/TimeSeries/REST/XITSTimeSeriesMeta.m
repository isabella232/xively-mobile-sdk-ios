//
//  XITSTimeSeriesMeta.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XITSTimeSeriesMeta.h"
#import "NSDateFormatter+XITimeSeries.h"

@interface XITSTimeSeriesMeta ()

@property(nonatomic, assign)NSInteger timeSpent;
@property(nonatomic, strong)NSDate *start;
@property(nonatomic, strong)NSDate *end;
@property(nonatomic, assign)NSInteger count;
@property(nonatomic, strong)NSString *pagingToken;

@end


@implementation XITSTimeSeriesMeta

@synthesize timeSpent = _timeSpent;
@synthesize start = _start;
@synthesize end = _end;
@synthesize count = _count;
@synthesize pagingToken = _pagingToken;

- (instancetype)initWithTimeSeries:(NSInteger)timeSpent start:(NSDate *)start end:(NSDate *)end count:(NSInteger)count pagingToken:(NSString *)pagingToken {
    self = [super init];
    if (self) {
        self.timeSpent = timeSpent;
        self.start = start;
        self.end = end;
        self.count = count;
        self.pagingToken = pagingToken;
    }
    return self;
}
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSDateFormatter *dateFormatter = [NSDateFormatter timeSeriesDateFormatter];
    NSInteger timeSpent = dictionary[@"timeSpent"] ? [dictionary[@"timeSpent"] integerValue] : 0;
    NSDate *start = dictionary[@"start"] ? [dateFormatter dateFromString:(NSString *)dictionary[@"start"]] : nil;
    NSDate *end = dictionary[@"end"] ? [dateFormatter dateFromString:(NSString *)dictionary[@"end"]] : nil;
    NSInteger count = dictionary[@"count"] ? [dictionary[@"count"] integerValue] : 0;
    NSString *pagingToken = dictionary[@"pagingToken"];
    
    return [self initWithTimeSeries:timeSpent
                              start:start
                                end:end
                              count:count
                        pagingToken:pagingToken];

}

@end

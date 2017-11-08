//
//  XITSTimeSeriesMeta.h
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XITSTimeSeriesMeta : NSObject

@property(nonatomic, readonly)NSInteger timeSpent;
@property(nonatomic, readonly)NSDate *start;
@property(nonatomic, readonly)NSDate *end;
@property(nonatomic, readonly)NSInteger count;
@property(nonatomic, readonly)NSString *pagingToken;

- (instancetype)initWithTimeSeries:(NSInteger)timeSpent start:(NSDate *)start end:(NSDate *)end count:(NSInteger)count pagingToken:(NSString *)pagingToken;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

//
//  XITSTimeSeriesCall.h
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XITSTimeSeriesMeta.h"

@protocol XITSTimeSeriesCall;

@protocol XITSTimeSeriesCallDelegate <NSObject>

- (void)timeSeriesCall:(id<XITSTimeSeriesCall>)timeSeriesCall didSucceedWithTimeSeriesItems:(NSArray *)timeSeriesItems meta:(XITSTimeSeriesMeta *)meta;
- (void)timeSeriesCall:(id<XITSTimeSeriesCall>)timeSeriesCall didFailWithError:(NSError *)error;

@end


@protocol XITSTimeSeriesCall <NSObject>

@property(nonatomic, weak)id<XITSTimeSeriesCallDelegate> delegate;

- (void)requestWithTopic:(NSString *)topic
              startDate:(NSDate *)startDate
                endDate:(NSDate *)endDate
                pageSize:(NSInteger)pageSize
             pagingToken:(NSString *)pagingToken;

- (void)cancel;

@end

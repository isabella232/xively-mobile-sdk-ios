//
//  XITimeSeriesProxy.m
//  common-iOS
//
//  Created by vfabian on 15/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XITimeSeriesProxy.h"

@interface XITimeSeriesProxy () {
@private
    id<XITimeSeries> _internal;
}
@end

@implementation XITimeSeriesProxy

- (XITimeSeriesState)state {
    return _internal.state;
}

- (void)setDelegate:(id<XITimeSeriesDelegate>)delegate {
    _internal.delegate = delegate;
}

- (id<XITimeSeriesDelegate>)delegate {
    return _internal.delegate;
}

- (NSError *)error {
    return _internal.error;
}

- (instancetype)initWithInternal:(id<XITimeSeries>)internal {
    assert(internal);
    self = [super init];
    if (self) {
        _internal = internal;
    }
    return self;
}

- (void)requestTimeSeriesItemsForChannel:(NSString *)channel startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [_internal requestTimeSeriesItemsForChannel:[NSString stringWithString:channel]
                                      startDate:[[NSDate alloc] initWithTimeInterval:0 sinceDate:startDate]
                                        endDate:[[NSDate alloc] initWithTimeInterval:0 sinceDate:endDate]];
}

- (void)cancel {
    [_internal cancel];
}

@end

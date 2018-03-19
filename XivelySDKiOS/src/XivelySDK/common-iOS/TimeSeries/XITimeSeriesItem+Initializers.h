//
//  XITimeSeriesItem.h
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/TimeSeries/XITimeSeriesItem.h>

@interface XITimeSeriesItem (Initializers)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithTime:(NSDate *)time category:(NSString *)category stringValue:(NSString *)stringValue numericValue:(NSNumber *)numericValue;

@end

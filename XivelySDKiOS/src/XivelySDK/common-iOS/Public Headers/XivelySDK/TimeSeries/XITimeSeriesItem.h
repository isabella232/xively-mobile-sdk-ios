//
//  XITimeSeriesItem.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file */

/**
 * @brief A time series item.
 * @since Version 1.0
 */
@interface XITimeSeriesItem : NSObject

/**
 * @brief The time of the item persisted to time series.
 * @since Version 1.0
 */
@property (nonatomic, readonly)NSDate *time;

/**
 * @brief The category of the item.
 * @since Version 1.0
 */
@property (nonatomic, readonly)NSString *category;

/**
 * @brief The string value of the persisted item.
 * @since Version 1.0
 */
@property (nonatomic, readonly)NSString *stringValue;

/**
 * @brief The numeric value of the persisted item.
 * @since Version 1.0
 */
@property (nonatomic, readonly)NSNumber *numericValue;

@end
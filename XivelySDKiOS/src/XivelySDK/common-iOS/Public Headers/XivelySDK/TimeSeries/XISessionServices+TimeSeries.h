//
//  XISessionServices+TimeSeries.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/XISessionServices.h>
#import <XivelySDK/TimeSeries/XITimeSeries.h>

/** @file */

/**
 * @brief Category for creating time series request objects.
 * @since Version 1.0
 */
@interface XISessionServices (TimeSeries)

/**
 * @brief Creates a time series query listing object.
 * @returns An object that implements \link XITimeSeries \endlink protocol.
 * @since Version 1.0
 */
- (id<XITimeSeries>)timeSeries;

@end



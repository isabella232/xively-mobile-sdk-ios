//
//  XITimeSeries.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file */

@protocol XITimeSeries;

/**
 * @brief The current state of the request to time series.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XITimeSeriesState) {
    XITimeSeriesStateIdle,         /**< The object is created but not started yet. @since Version 1.0 */
    XITimeSeriesStateRunning,       /**< The listing is running. @since Version 1.0 */
    XITimeSeriesStateEnded,        /**< The listing ended successfully. @since Version 1.0 */
    XITimeSeriesStateError,        /**< The listing ended with an error. @since Version 1.0 */
    XITimeSeriesStateCanceled,     /**< The listing was canceled. @since Version 1.0 */
};

/**
 * @brief The delegate for time series responses.
 * @since Version 1.0
 */
@protocol XITimeSeriesDelegate <NSObject>

/**
 * @brief The time series request finished with success.
 * @param timeSeries The timeSeries instance that initiates the callback.
 * @param timeSeriesItems The result time series items. They are all instances of \link XITimeSeriesItem\endlink.
 * @since Version 1.0
 */
- (void)timeSeries:(id<XITimeSeries>)timeSeries didReceiveItems:(NSArray *)timeSeriesItems;

/**
 * @brief The time series request finished with an error.
 * @param timeSeries The timeSeries instance that initiates the callback.
 * @param error The reason of the error. The possible error codes are defined in \link XICommonError.h \endlink and \link XITimeSeriesError.h \endlink.
 * @since Version 1.0
 */
- (void)timeSeries:(id<XITimeSeries>)timeSeries didFailWithError:(NSError *)error;

@end


/**
 * @brief Interface for objects that perform time series listing.
 * @since Version 1.0
 */
@protocol XITimeSeries <NSObject>

/**
 * @brief The state of the ime series object.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XITimeSeriesState state;

/**
 * @brief The delegate to call back the time series result on.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XITimeSeriesDelegate> delegate;

/**
 * @brief The error if the time series listing finished with error.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *error;

/**
 * @brief Request time series data for the given channel in the given time range.
 * @param channel The channel that the time series query is requested for.
 * @param startDate The start time of the request.
 * @param endDate The end time of the request.
 * @since Version 1.0
 */
- (void)requestTimeSeriesItemsForChannel:(NSString *)channel startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

/**
 * @brief Cancel the time series listing.
 * @since Version 1.0
 */
- (void)cancel;

@end
//
//  XIServiceCreator.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file */

/**
 * @brief Service Creator states.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIServiceCreatorState) {
    XIServiceCreatorStateIdle,      /**< The creator is not started yet. @since Version 1.0 */
    XIServiceCreatorStateCreating,  /**< Creating the service. @since Version 1.0 */
    XIServiceCreatorStateCreated,   /**< The service is already created. @since Version 1.0 */
    XIServiceCreatorStateError,     /**< The service creation failed with an error. @since Version 1.0 */
    XIServiceCreatorStateCanceled   /**< The service creation was canceled. @since Version 1.0 */
};

/**
 * @brief A general protocol for any Xively service creation.
 * @details This interface is for checking the creation state. The creation process also can be canceled here if it is not needed.
 * @since Version 1.0
 */
@protocol XIServiceCreator <NSObject>

/**
 * @brief The current state.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIServiceCreatorState state;

/**
 * @brief The created service if the creation was successfull.
 * @since Version 1.0
 */
@property(nonatomic, readonly)id<NSObject> result;

/**
 * @brief If the creation failed, it contains the error reason.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *error;

/**
 * @brief The delegate to call back on the service creation result.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<NSObject> delegate;

/**
 * @brief Cancel the creation.
 * @since Version 1.0
 */
- (void)cancel;

@end
//
//  XIDeviceAssociation.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file */

@protocol XIDeviceAssociation;

/**
 * @brief The current state of the authentication.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIDeviceAssociationState) {
    XIDeviceAssociationStateIdle,         /**< The object is created but not started yet. @since Version 1.0 */
    XIDeviceAssociationStateAssociating,  /**< The association is running. @since Version 1.0 */
    XIDeviceAssociationStateEnded,        /**< The association ended successfully. @since Version 1.0 */
    XIDeviceAssociationStateError,        /**< The association ended with an error. @since Version 1.0 */
    XIDeviceAssociationStateCanceled,     /**< The association was canceled. @since Version 1.0 */
};

/**
 * @brief The delegate for device association.
 * @since Version 1.0
 */
@protocol XIDeviceAssociationDelegate <NSObject>

/**
 * @brief The association finished with success.
 * @param deviceAssociation The deviceAssociation instance that initiates the callback.
 * @param deviceId The ID of the associated device.
 * @since Version 1.0
 */
- (void)deviceAssociation:(id<XIDeviceAssociation>)deviceAssociation didSucceedWithDeviceId:(NSString *)deviceId;

/**
 * @brief The association finished with an error.
 * @param deviceAssociation The deviceAssociation instance that initiates the callback.
 * @param error The reason of the error. The possible error codes are defined in \link XICommonError.h \endlink and \link XIDeviceAssociationError.h \endlink.
 * @since Version 1.0
 */
- (void)deviceAssociation:(id<XIDeviceAssociation>)deviceAssociation didFailWithError:(NSError *)error;

@end

/**
 * @brief Interface for objects that do IoT device assiciation to an end user.
 * @since Version 1.0
 */
@protocol XIDeviceAssociation <NSObject>

/**
 * @brief The state of the activation object.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIDeviceAssociationState state;

/**
 * @brief The delegate to call back the association result on.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XIDeviceAssociationDelegate> delegate;

/**
 * @brief The error if the authentication finished with error.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *error;

/**
 * @brief Begin association of the IoT device to the current user, that the activation code belongs to.
 * @param associationCode The association code of the IoT device to be assigned to the current end user.
 * @since Version 1.0
 */
- (void)associateDeviceWithAssociationCode:(NSString *)associationCode;

/**
 * @brief Cancel the association.
 * @since Version 1.0
 */
- (void)cancel;

@end

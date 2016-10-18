//
//  XIOrganizationHandler.h
//  common-iOS
//
//  Created by tkorodi on 16/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/OrganizationInfo/XIOrganizationInfo.h>

@protocol XIOrganizationHandler;

/**
 * @brief The current state of the organization info listing.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIOrganizationHandlerState) {
    XIOrganizationHandlerStateIdle,         /**< The object is created but not started yet. @since Version 1.0 */
    XIOrganizationHandlerStateRunning,      /**< The listing is running. @since Version 1.0 */
    XIOrganizationHandlerStateEnded,        /**< The listing ended successfully. @since Version 1.0 */
    XIOrganizationHandlerStateError,        /**< The listing ended with an error. @since Version 1.0 */
    XIOrganizationHandlerStateCanceled,     /**< The listing was canceled. @since Version 1.0 */
};

/**
 * @brief The delegate for device info listing.
 * @since Version 1.0
 */
@protocol XIOrganizationHandlerDelegate <NSObject>

/**
 * @brief The organization info listing finished with success.
 * @param organizationHandler The organizationHandler instance that initiates the callback.
 * @param organizationInfos The organization info container objects. They are all instances of \link XIOrganizationInfo\endlink.
 * @since Version 1.0
 */
- (void)organizationHandler:(id<XIOrganizationHandler>)organizationhandler didReceiveList:(NSArray *)organizationInfos;


/**
 * @brief The organization info query finished with success.
 * @param organizationHandler The organizationHandler instance that initiates the callback.
 * @param organizationInfo The organization info object.
 * @since Version 1.0
 */
- (void)organizationHandler:(id<XIOrganizationHandler>)organizationHandler didReceiveOrganizationInfo:(XIOrganizationInfo *)organizationInfo;

/**
 * @brief The association finished with an error.
 * @param organizationHandler The XIOrganizationHandler instance that initiates the callback.
 * @param error The reason of the error. The possible error codes are defined in \link XICommonError.h \endlink.
 * @since Version 1.0
 */
- (void)organizationHandler:(id<XIOrganizationHandler>)organizationHandler didFailWithError:(NSError *)error;

@end


/**
 * @brief Interface for objects that holds IoT organization info that are accessible.
 * @since Version 1.0
 */
@protocol XIOrganizationHandler <NSObject>

/**
 * @brief The state of the handler object.
 * @since Version 1.0
 */
@property(nonatomic, readonly)XIOrganizationHandlerState state;

/**
 * @brief The delegate to call back the result on.
 * @since Version 1.0
 */
@property(nonatomic, weak)id<XIOrganizationHandlerDelegate> delegate;

/**
 * @brief The error if the query finished with error.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSError *error;

/**
 * @brief Request organization info identified by organizationId asynchronously.
 * @since Version 1.0
 */
- (void)requestOrganization:(NSString*)organizationId;

/**
 * @brief List all organiaztions
 * @since Version 1.0
 */
- (void)listOrganizations;

/**
 * @brief Cancel the query.
 * @since Version 1.0
 */
- (void)cancel;

@end
//
//  XIAccess.h
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file */

/**
 * @brief This class holds the XI related credentials, and it initiates the XI Engagement session.
 * @since Version 1.0
 */
typedef NS_ENUM(NSUInteger, XIAccessBlueprintUserType) {
    XIAccessBlueprintUserTypeUndefined,     /**< The user type is not defined. @since Version 1.0 */
    XIAccessBlueprintUserTypeEndUser,       /**< An end user. @since Version 1.0 */
    XIAccessBlueprintUserTypeAccountUser,   /**< An account user. @since Version 1.0 */
};

/**
 * @brief This class holds the XI related credentials, and it initiates the XI Engagement session.
 * @since Version 1.0
 */
@interface XIAccess : NSObject

/**
 * @brief The account id of the access. It is set in the initialization.
 * @since Version 1.0
 */
@property(nonatomic, copy)NSString *accountId;

/**
 * @brief The username to connect with.
 * @since Version 1.0
 */
@property(nonatomic, copy, readonly)NSString *mqttUsername;

/**
 * @brief The password to connect with.
 * @since Version 1.0
 */
@property(nonatomic, copy)NSString *mqttPassword;

/**
 * @brief The device id to connect with.
 * @since Version 1.0
 */
@property(nonatomic, copy)NSString *mqttDeviceId;

/**
 * @brief The JSON Web Token used in REST calls.
 * @since Version 1.0
 */
@property(nonatomic, copy)NSString *jwt;


/**
 * @brief The User ID of the User in IDM.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSString *idmUserId;

/**
 * @brief The Blueprint user type.
 * @since Version 1.0
 */
@property(nonatomic, assign)XIAccessBlueprintUserType blueprintUserType;


/**
 * @brief The account user id if the user is an account user. The end user id if the user is an end user.
 * @since Version 1.0
 */
@property(nonatomic, copy)NSString *blueprintUserId;

/**
 * @brief The ID of the Blueprint Organization the current user belongs to.
 * @since Version 1.0
 */
@property(nonatomic, copy)NSString *blueprintOrganizationId;

/**
 * @brief The name of the logged in user.
 * @since Version 1.0
 */
@property(nonatomic, copy)NSString *blueprintUserName;

@end

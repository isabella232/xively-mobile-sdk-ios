//
//  XIOrganizationInfo.h
//  common-iOS
//
//  Created by tkorodi on 16/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

@interface XIOrganizationInfo : NSObject

/**
 * @brief All the device parameters in a dictionary form.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSDictionary *parameters;

/**
 * @brief All organization fields in a dictionary form.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSDictionary *customFields;

/**
 * @brief New/Changed Key-Value pairs for organization PUT.
 * @since Version 1.0
 */
@property(nonatomic)NSDictionary *fieldsToUpdate;

/**
 * @brief The id of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *organizationId;

/**
 * @brief The id of parent of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *parentId;


/**
 * @brief The db version of the organization object
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *version;

/**
 * @brief The name of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *name;

/**
 * @brief The description of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *desc;

/**
 * @brief The phone number of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *phoneNumber;

/**
 * @brief The address of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *address;

/**
 * @brief The city of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *city;

/**
 * @brief The state of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *state;

/**
 * @brief The postal code of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *postalCode;

/**
 * @brief The country code of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *countryCode;

/**
 * @brief The industry of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *industry;

/**
 * @brief The size of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *organizationSize;

/**
 * @brief The website URL of the organization
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *websiteAddress;


@end
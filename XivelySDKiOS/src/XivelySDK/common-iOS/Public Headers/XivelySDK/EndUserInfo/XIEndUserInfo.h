//
//  XIEndUserInfo.h
//  common-iOS
//
//  Created by tkorodi on 16/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

@interface XIEndUserInfo : NSObject

/*
 "version": "E0",
 "id": "0b9b236b-7d1b-489c-ab11-8b63afa2b67c",
 "address": null,
 "city": null,
 "countryCode": null,
 "emailAddress": null,
 "name": "Audie Harris",
 "phoneNumber": null,
 "postalCode": null,
 "state": null
 */

/**
 * @brief All the device parameters in a dictionary form.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSDictionary *parameters;

/**
 * @brief All end user fields in a dictionary form.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSDictionary *customFields;

/**
 * @brief New/Changed Key-Value pairs for end user PUT.
 * @since Version 1.0
 */
@property(nonatomic)NSDictionary *fieldsToUpdate;

/**
 * @brief The id of the EndUser
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *endUserId;

/**
 * @brief The db version of the EndUser object
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *version;

/**
 * @brief The name of the EndUser
 * @since Version 1.0
 */
@property (nonatomic) NSString *name;

/**
 * @brief The phone number of the EndUser
 * @since Version 1.0
 */
@property (nonatomic) NSString *phoneNumber;

/**
 * @brief The address of the EndUser
 * @since Version 1.0
 */
@property (nonatomic) NSString *address;

/**
 * @brief The email address of the EndUser
 * @since Version 1.0
 */
@property (nonatomic) NSString *emailAddress;

/**
 * @brief The city of the EndUser
 * @since Version 1.0
 */
@property (nonatomic) NSString *city;

/**
 * @brief The state of the EndUser
 * @since Version 1.0
 */
@property (nonatomic) NSString *state;

/**
 * @brief The postal code of the EndUser
 * @since Version 1.0
 */
@property (nonatomic) NSString *postalCode;

/**
 * @brief The country code of the EndUser
 * @since Version 1.0
 */
@property (nonatomic) NSString *countryCode;

@end
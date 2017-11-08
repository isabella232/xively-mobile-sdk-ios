//
//  XISessionServices+OrganizationHandler.h
//  common-iOS
//
//  Created by tkorodi on 16/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/XISessionServices.h>
#import <XivelySDK/OrganizationInfo/XIOrganizationInfo.h>
#import <XivelySDK/OrganizationInfo/XIOrganizationHandler.h>

/** @file */

/**
 * @brief Category for creating organization info objects.
 * @since Version 1.0
 */
@interface XISessionServices (OrganizationInfo)

/**
 * @brief Creates an organization handler object.
 * @returns An object that implements \link XIOrganizationHandler \endlink protocol.
 * @since Version 1.0
 */
- (id<XIOrganizationHandler>)organizationHandler;

@end

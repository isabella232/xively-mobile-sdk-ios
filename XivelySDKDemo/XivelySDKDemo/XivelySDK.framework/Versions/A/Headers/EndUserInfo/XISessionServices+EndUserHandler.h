//
//  XISessionServices+EndUserHandler.h
//  common-iOS
//
//  Created by tkorodi on 16/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/XISessionServices.h>
#import <XivelySDK/EndUserInfo/XIEndUserInfo.h>
#import <XivelySDK/EndUserInfo/XIEndUserHandler.h>

/** @file */

/**
 * @brief Category for creating EndUser info objects.
 * @since Version 1.0
 */
@interface XISessionServices (EndUserInfo)

/**
 * @brief Creates an EndUser handler object.
 * @returns An object that implements \link XIEndUserHandler \endlink protocol.
 * @since Version 1.0
 */
- (id<XIEndUserHandler>)endUserHandler;

@end

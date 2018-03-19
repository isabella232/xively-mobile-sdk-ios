//
//  XIRESTCallProvider.h
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XIRESTCall;

/**
 * @brief Interface for getting an empty rest call.
 * @since Version 1.0
 */
@protocol XIRESTCallProvider <NSObject>

/**
 * @brief Creates an empty REST call to be used.
 * @return The empty REST call to be used
 * @since Version 1.0
 */
- (id<XIRESTCall>)getEmptyRESTCall;

@end
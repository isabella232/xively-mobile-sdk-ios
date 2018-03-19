//
//  XIRESTCallDelegate.h
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XIRESTCall;


/**
 * @brief Interface for a rest call.
 * @since Version 1.0
 */
@protocol XIRESTCallDelegate <NSObject>

/**
 * @brief The call did finish with success.
 * @param call The call that finished.
 * @param data The received data.
 * @param httpStatusCode The http status code of response.
 * @since Version 1.0
 */
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithData:(NSData *)data httpStatusCode:(NSInteger)httpStatusCode;


/**
 * @brief The call did fail to finish.
 * @param call The call that finished.
 * @param error The received error.
 * @since Version 1.0
 */
- (void)XIRESTCall:(id<XIRESTCall>)call didFinishWithError:(NSError *)error;
@end


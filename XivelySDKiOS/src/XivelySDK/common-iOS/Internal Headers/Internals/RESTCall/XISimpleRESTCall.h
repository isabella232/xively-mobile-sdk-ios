//
//  XISimpleRESTCall.h
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Internals/RESTCall/XIRESTCall.h>
#import <Internals/RESTCall/XIRESTDefaultHeadersProvider.h>

/**
 * @brief XIRESTCall implementation with NSURLSession. it only works with iOS 7 and later.
 * @since Version 1.0
 */
@interface XISimpleRESTCall : NSObject <XIRESTCall>

/**
 * @brief The constructor.
 * @param urlSession The URL connection to use for connecting.
 * @param defaultHeadersProvider The provider of the default HTTP headers.
 * @param responseRecognizers Instances if \link XIRESTCallResponseRecognizer \endlink.
 * @returns An XIRESTCallInternal object.
 * @since Version 1.0
 */
- (instancetype)initWithURLSession:(NSURLSession *)urlSession
            defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)defaultHeadersProvider
               responseRecognizers:(NSArray *)responseRecognizers;

/**
 * @brief The static constructor.
 * @param urlSession The URL connection to use for connecting.
 * @param defaultHeadersProvider The provider of the default HTTP headers.
 * @param responseRecognizers Instances if \link XIRESTCallResponseRecognizer \endlink.
 * @returns An XIRESTCallInternal object.
 * @since Version 1.0
 */
+ (instancetype)restCallInternalWithURLSession:(NSURLSession *)urlSession
                        defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)defaultHeadersProvider
                           responseRecognizers:(NSArray *)responseRecognizers;

@end

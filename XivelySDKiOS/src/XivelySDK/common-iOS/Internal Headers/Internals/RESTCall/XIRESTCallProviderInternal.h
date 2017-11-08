//
//  XIRESTCallProviderInternal.h
//  common-iOS
//
//  Created by vfabian on 12/02/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XivelySDK/XISdkConfig.h>
#import <Internals/RESTCall/XIRobustRESTCall.h>
#import <Internals/RESTCall/XIRESTCallProvider.h>
#import <Internals/RESTCall/XIRESTDefaultHeadersProvider.h>

/**
 * @brief XIRESTCallProviderInternal implementation.
 * @since Version 1.0
 */
@interface XIRESTCallProviderInternal : NSObject <XIRESTCallProvider, XIRobustRESTCallSimpleCallProvider>

/**
 * @brief Constructor.
 * @param config The config for the internal execution of the SDK.
 * @param defaultHeadersProvider The provider of the default HTTP headers.
 * @param responseRecognizers Instances if \link XIRESTCallResponseRecognizer \endlink.
 * @returns An instance of XIRESTCallProviderInternal.
 * @since Version 1.0
 */
- (instancetype)initWithConfig:(XISdkConfig *)config
        defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)defaultHeadersProvider
           responseRecognizers:(NSArray *)responseRecognizers;

/**
 * @brief Static constructor.
 * @param config The config for the internal execution of the SDK.
 * @param defaultHeadersProvider The provider of the default HTTP headers.
 * @param responseRecognizers Instances if \link XIRESTCallResponseRecognizer \endlink.
 * @returns An instance of XIRESTCallProviderInternal.
 * @since Version 1.0
 */
+ (instancetype)restCallProviderWithConfig:(XISdkConfig *)config
                    defaultHeadersProvider:(XIRESTDefaultHeadersProvider *)defaultHeadersProvider
                       responseRecognizers:(NSArray *)responseRecognizers;

@end

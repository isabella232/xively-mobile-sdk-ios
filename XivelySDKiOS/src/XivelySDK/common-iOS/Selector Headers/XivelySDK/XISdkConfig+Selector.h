//
//  XISdkConfig+Selector.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/XIEnvironment.h>

/** @file */

/**
 * @brief The environment selection enabled SDK Config category.
 * @since Version 1.0
 */
@interface XISdkConfig (Selector)

/**
 * @brief The environment the SDK connects to.
 * @since Version 1.0
 */
@property (nonatomic, readonly)XIEnvironment environment;

/**
 * @brief Static constructor for creating a config with default settings.
 * @param environment The environment the SDK connects to.
 * @returns An XISessionConfig object.
 * @since Version 1.0
 */
+ (instancetype)configWithEnvironment:(XIEnvironment)environment;

/**
 * @brief Static constructor.
 * @param httpResponseTimeout The timeout for any HTTP request in seconds.
 * @param urlSession The URL session that is used for HTTP calls.
 * @param mqttConnectTimeout The timeout of the initial mqtt connection.
 * @param mqttRetryAttempt The number of attempts an MQTT connection is tried to build up if it fails.
 * @param mqttWaitOnReconnect The the time spent between an MQTT connection error and the next connection retry attempt in seconds.
 * @param environment The environment the SDK connects to.
 * @returns An XISessionConfig object.
 * @since Version 1.0
 */
+ (instancetype)configWithHTTPResponseTimeout:(long)httpResponseTimeout
                                   urlSession:(NSURLSession *)urlSession
                           mqttConnectTimeout:(long)mqttConnectTimeout
                             mqttRetryAttempt:(int)mqttRetryAttempt
                          mqttWaitOnReconnect:(long)mqttWaitOnReconnect
                                  environment:(XIEnvironment)environment;

/**
 * @brief Initialization with default parameters and environment selection.
 * @param environment The environment the SDK connects to.
 * @since Version 1.0
 */
-(instancetype)initWithEnvironment:(XIEnvironment)environment;

/**
 * @brief Constructor.
 * @param httpResponseTimeout The timeout for any HTTP request in seconds.
 * @param urlSession The URL session that is used for HTTP calls.
 * @param mqttConnectTimeout The timeout of the initial mqtt connection.
 * @param mqttRetryAttempt The number of attempts an MQTT connection is tried to build up if it fails.
 * @param mqttWaitOnReconnect The the time spent between an MQTT connection error and the next connection retry attempt in seconds.
 * @param environment The environment the SDK connects to.
 * @returns An XISessionConfig object.
 * @since Version 1.0
 */
- (instancetype)initWithHTTPResponseTimeout:(long)httpResponseTimeout
                                 urlSession:(NSURLSession *)urlSession
                         mqttConnectTimeout:(long)mqttConnectTimeout
                           mqttRetryAttempt:(int)mqttRetryAttempt
                        mqttWaitOnReconnect:(long)mqttWaitOnReconnect
                                environment:(XIEnvironment)environment;

@end


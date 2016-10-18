//
//  XISessionConfig.h
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/XILogLevel.h>

/** @file */

/**
 * @brief Configurations to set up the internal behavior of the SDK.
 * @details The session config is for fine tunning the SDK behavior. At this moment network
 * handling parameters can be set here.
 * @since Version 1.0
 */
@interface XISdkConfig : NSObject

/**
 * @brief The timeout for any HTTP request in seconds.
 * @details It is the overall timeout for any HTTP call which applies disregarding the retry attempt
 * count and the waiting time between them. The default value is 15s.
 * @since Version 1.0
 */
@property(nonatomic, readonly)long httpResponseTimeout;

/**
 * @brief The URL session that is used for HTTP calls.
 * @details The default is an url session with default configuration.
 * @since Version 1.0
 */
@property(nonatomic, readonly)NSURLSession *urlSession;


/**
 * @brief The timeout of the initial mqtt connection.
 * @details The default is 15s.
 * @since Version 1.0
 */
@property(nonatomic, readonly)long mqttConnectTimeout;

/**
 * @brief The number of attempts an MQTT connection is tried to build up if it fails.
 * @details The default is 3.
 * @since Version 1.0
 */
@property(nonatomic, readonly)int mqttRetryAttempt;

/**
 * @brief The the time spent between an MQTT connection error and the next connection retry attempt in seconds.
 * @details The default is 2s.
 * @since Version 1.0
 */
@property(nonatomic, readonly)long mqttWaitOnReconnect;

/**
 * @brief Set and get the SDK's log level. The default is warning level.
 * @details The default is 2s.
 * @since Version 1.0
 */
@property(nonatomic) XILogLevel logLevel;

/**
 * @brief Static constructor for creating a config with default settings.
 * @returns An XISessionConfig object.
 * @since Version 1.0
 */
+ (instancetype)config;

/**
 * @brief Static constructor.
 * @param httpResponseTimeout The timeout for any HTTP request in seconds.
 * @param urlSession The URL session that is used for HTTP calls.
 * @param mqttConnectTimeout The timeout of the initial mqtt connection.
 * @param mqttRetryAttempt The number of attempts an MQTT connection is tried to build up if it fails.
 * @param mqttWaitOnReconnect The the time spent between an MQTT connection error and the next connection retry attempt in seconds.
 * @returns An XISessionConfig object.
 * @since Version 1.0
 */
+ (instancetype)configWithHTTPResponseTimeout:(long)httpResponseTimeout
                                  urlSession:(NSURLSession *)urlSession
                          mqttConnectTimeout:(long)mqttConnectTimeout
                            mqttRetryAttempt:(int)mqttRetryAttempt
                         mqttWaitOnReconnect:(long)mqttWaitOnReconnect;

/**
 * @brief Constructor  for creating a config with default settings.
 * @returns An XISessionConfig object.
 * @since Version 1.0
 */
- (instancetype)init;

/**
 * @brief Constructor.
 * @param httpResponseTimeout The timeout for any HTTP request in seconds.
 * @param urlSession The URL session that is used for HTTP calls.
 * @param mqttConnectTimeout The timeout of the initial mqtt connection.
 * @param mqttRetryAttempt The number of attempts an MQTT connection is tried to build up if it fails.
 * @param mqttWaitOnReconnect The the time spent between an MQTT connection error and the next connection retry attempt in seconds.
 * @returns An XISessionConfig object.
 * @since Version 1.0
 */
- (instancetype)initWithHTTPResponseTimeout:(long)httpResponseTimeout
                                  urlSession:(NSURLSession *)urlSession
                          mqttConnectTimeout:(long)mqttConnectTimeout
                            mqttRetryAttempt:(int)mqttRetryAttempt
                         mqttWaitOnReconnect:(long)mqttWaitOnReconnect;


/**
 * @brief The current version of the SDK.
 * @returns The current version of the SDK.
 * @since Version 1.0
 */
+ (NSString *)version;
@end

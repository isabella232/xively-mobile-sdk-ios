//
//  XISessionServicesInternal.h
//  common-iOS
//
//  Created by vfabian on 15/01/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <XivelySDK/XISessionServices.h>
#import <XivelySDK/DeviceInfo/XIDeviceInfoList.h>
#import <XivelySDK/DeviceInfo/XIDeviceHandler.h>
#import <XivelySDK/OrganizationInfo/XIOrganizationHandler.h>
#import <XivelySDK/TimeSeries/XITimeSeries.h>
// #import <XivelySDK/DeviceAssociation/XIDeviceAssociation.h>
#import <XivelySDK/Messaging/XIMessagingCreator.h>
#import <XICommonInternals.h>

/** @file */

/**
 * @brief The implementation of the service creator.
 * @since Version 1.0
 */
@interface XISessionServicesInternal : NSObject

/**
 * @brief The static constructor.
 * @param session The session implementation.
 * @returns An XISessionServicesInternal object.
 * @since Version 1.0
 */
+ (instancetype)servicesWithSession:(XISessionInternal *)session;

/**
 * @brief The constructor.
 * @param session The session implementation.
 * @returns An XISessionServicesInternal object.
 * @since Version 1.0
 */
- (instancetype)initWithSession:(XISessionInternal *)session;

/**
 * @brief Create a service that uses one call to provide a service.
 * @param callProviderClass The class of the provider of the calls. This class needs to conform to \link XISessionServicesCallProvider \endlink protocol.
 * @param internalClass The class of the internal implementation of the service. It needs to conform to \link XISessionServiceWithCallProvider \endlink protocol.
 * @param proxyClass The class of the proxy. It needs to conform to \link XISessionServiceProxy \endlink protocol.
 * @param logger The logger instance.
 * @returns An instance of the proxy class that owns and refers to an internal object.
 * @since Version 1.0
 */
- (id)serviceWithCallProviderClass:(Class)callProviderClass
                     internalClass:(Class)internalClass
                        proxyClass:(Class)proxyClass
                            logger:(id<XICOLogging>)logger;

/**
 * @brief Create a service that uses the MQTT connection pool.
 * @param internalClass The class of the internal implementation of the service. It needs to conform to \link XISessionServiceWithConnectionPool \endlink protocol.
 * @param proxyClass The class of the proxy. It needs to conform to \link XISessionServiceProxy \endlink protocol.
 * @param logger The logger instance.
 * @returns An instance of the proxy class that owns and refers to an internal object.
 * @since Version 1.0
 */
- (id)serviceUsingConnectionPoolWithInternalClass:(Class)internalClass
                                       proxyClass:(Class)proxyClass
                                           logger:(id<XICOLogging>)logger;

/**
 * @brief Create a service that needst the session internal class.
 * @param internalClass The class of the internal implementation of the service. It needs to conform to \link XISessionServiceWithConnectionPool \endlink protocol.
 * @param proxyClass The class of the proxy. It needs to conform to \link XISessionServiceProxy \endlink protocol.
 * @param logger The logger instance.
 * @returns An instance of the proxy class that owns and refers to an internal object.
 * @since Version 1.0
 */
- (id)serviceUsingSessionInternalWithInternalClass:(Class)internalClass
                                        proxyClass:(Class)proxyClass
                                            logger:(id<XICOLogging>)logger;

/**
 * @brief Creates a device info lising object.
 * @returns An XIDeviceInfoList object.
 * @since Version 1.0
 */
- (id<XIDeviceInfoList>)deviceInfoList;

/**
 * @brief Creates a device handler object.
 * @returns An XIDeviceHandler object.
 * @since Version 1.0
 */
- (id<XIDeviceHandler>)deviceHandler;

/**
 * @brief Creates a time series request object.
 * @returns An XITimeSeries object.
 * @since Version 1.0
 */
- (id<XITimeSeries>)timeSeries;

/**
 * @brief Creates an organization handler object.
 * @returns An XIOrganizationHandler object.
 * @since Version 1.0
 */
- (id<XIOrganizationHandler>)organizationHandler;

/**
 * @brief Creates an endUser handler object.
 * @returns An XIOrganizationHandler object.
 * @since Version 1.0
 */
- (id<XIOrganizationHandler>)endUserHandler;

/**
 * @brief Creates a device association object.
 * @returns An XIDeviceAssociation object.
 * @since Version 1.0
 */
// TBD - (id<XIDeviceAssociation>)deviceAssociation;

/**
 * @brief Creates a messaging creator object.
 * @returns An XIMessagingCreator object.
 * @since Version 1.0
 */
- (id<XIMessagingCreator>)messagingCreator;

@end

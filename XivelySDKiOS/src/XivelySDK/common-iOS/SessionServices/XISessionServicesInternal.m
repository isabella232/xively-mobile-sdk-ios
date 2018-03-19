//
//  XISessionServicesInternal.m
//  common-iOS
//
//  Created by vfabian on 15/01/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XISessionServicesInternal.h"
#import "XISessionInternal.h"

#import "XIDADeviceAssociationRestCallProvider.h"

#import "XICOConnectionPool.h"

// TBD #import "XIDADeviceAssociation.h"
// TBD #import "XIDeviceAssociationProxy.h"
// TBD #import "XIDADeviceAssociationRestCallProvider.h"

#import "XIMSGMessagingCreator.h"
#import "XIMessagingCreatorProxy.h"

#import "XIDeviceInfoListProxy.h"
#import "XIDIDeviceInfoList.h"
#import "XIDIDeviceInfoListRestCallProvider.h"

#import "XIDIDeviceHandler.h"
#import "XIDeviceInfoRestCallProvider.h"
#import "XIDIDeviceHandlerProxy.h"

#import "XIOROrganizationHandler.h"
#import "XIOrganizationInfoRestCallProvider.h"
#import "XIOROrganizationHandler.h"
#import "XIOROrganizationHandlerProxy.h"

#import "XIEUEndUserHandler.h"
#import "XIEndUserInfoRestCallProvider.h"
#import "XIEUEndUserHandler.h"
#import "XIEUEndUserHandlerProxy.h"

#import "XITSTimeSeries.h"
#import "XITimeSeriesProxy.h"
#import "XITSTimeSeriesRestCallProvider.h"

#import "XISessionServiceProxy.h"
#import "XISessionServiceWithCallProvider.h"
#import "XISessionServicesCallProvider.h"
#import "XISessionServiceWithConnectionPool.h"
#import "XISessionServiceWithSessionInternal.h"

@interface XISessionServicesInternal () {
@protected
    __weak XISessionInternal *_session;
}

@end

@implementation XISessionServicesInternal

+ (instancetype)servicesWithSession:(XISessionInternal *)session {
    return [[[self class] alloc] initWithSession:session];
}

- (instancetype)initWithSession:(XISessionInternal *)session {
    self = [super init];
    if (self) {
        assert(session);
        _session = session;
    }
    return self;
}

- (id)serviceWithCallProviderClass:(Class)callProviderClass
                     internalClass:(Class)internalClass
                        proxyClass:(Class)proxyClass
                            logger:(id<XICOLogging>)logger {
    assert(!_session.suspended);
    id<XISessionServicesCallProvider> provider = [callProviderClass alloc];
    provider = [provider initWithLogger:logger restCallProvider:_session.restCallProvider servicesConfig:_session.servicesConfig];
    
    id<XISessionServiceWithCallProvider> internal = [internalClass alloc];
    internal = [internal initWithLogger:logger
                           callProvider:provider
                                  proxy:nil
                                 access:_session.access
                          notifications:_session.notifications
                                 config:_session.servicesConfig];
    
    id<XISessionServiceProxy> proxy = [proxyClass alloc];
    proxy = [proxy initWithInternal:internal];
    internal.proxy = proxy;
    
    return proxy;
}

- (id)serviceUsingConnectionPoolWithInternalClass:(Class)internalClass
                                       proxyClass:(Class)proxyClass
                                           logger:(id<XICOLogging>)logger {
    assert(!_session.suspended);
    
    id<XISessionServiceWithConnectionPool> internal = [internalClass alloc];
    internal = [internal initWithLogger:logger
                                  proxy:nil
                                    jwt:_session.access.jwt
                         connectionPool:_session.connectionPool
                          notifications:_session.notifications];
    
    id<XISessionServiceProxy> proxy = [proxyClass alloc];
    proxy = [proxy initWithInternal:internal];
    internal.proxy = proxy;
    
    return proxy;
}

- (id)serviceUsingSessionInternalWithInternalClass:(Class)internalClass
                                       proxyClass:(Class)proxyClass
                                           logger:(id<XICOLogging>)logger {
    assert(!_session.suspended);
    id<XISessionServiceWithSessionInternal> internal = [internalClass alloc];
    internal = [internal initWithSession:_session];
    
    id<XISessionServiceProxy> proxy = [proxyClass alloc];
    proxy = [proxy initWithInternal:internal];
    internal.proxy = proxy;
    
    return proxy;
}


- (id<XIDeviceInfoList>)deviceInfoList {
    id<XICOLogging> logger = [[XICOLogger sharedLogger] createLoggerWithFacility:@"Device Info List"];
    return (id<XIDeviceInfoList>)[self serviceWithCallProviderClass:[XIDIDeviceInfoListRestCallProvider class]
                                                      internalClass:[XIDIDeviceInfoList class]
                                                         proxyClass:[XIDeviceInfoListProxy class]
                                                             logger:logger];
}

- (id<XIDeviceHandler>)deviceHandler {
    id<XICOLogging> logger = [[XICOLogger sharedLogger] createLoggerWithFacility:@"Device Handler"];
    return (id<XIDeviceHandler>)[self serviceWithCallProviderClass:[XIDeviceInfoRestCallProvider class]
                                                      internalClass:[XIDIDeviceHandler class]
                                                         proxyClass:[XIDIDeviceHandlerProxy class]
                                                             logger:logger];
}

- (id<XIOrganizationHandler>)organizationHandler {
    id<XICOLogging> logger = [[XICOLogger sharedLogger] createLoggerWithFacility:@"Organization Handler"];
    return (id<XIOrganizationHandler>)[self serviceWithCallProviderClass:[XIOrganizationInfoRestCallProvider class]
                                                     internalClass:[XIOROrganizationHandler class]
                                                        proxyClass:[XIOROrganizationHandlerProxy class]
                                                            logger:logger];
}

- (id<XIOrganizationHandler>)endUserHandler {
    id<XICOLogging> logger = [[XICOLogger sharedLogger] createLoggerWithFacility:@"End Handler"];
    return (id<XIOrganizationHandler>)[self serviceWithCallProviderClass:[XIEndUserInfoRestCallProvider class]
                                                           internalClass:[XIEUEndUserHandler class]
                                                              proxyClass:[XIEUEndUserHandlerProxy class]
                                                                  logger:logger];
}

- (id<XITimeSeries>)timeSeries {
    id<XICOLogging> logger = [[XICOLogger sharedLogger] createLoggerWithFacility:@"Time Series"];
    return (id<XITimeSeries>)[self serviceWithCallProviderClass:[XITSTimeSeriesRestCallProvider class]
                                                      internalClass:[XITSTimeSeries class]
                                                         proxyClass:[XITimeSeriesProxy class]
                                                             logger:logger];
}

/* TBD - (id<XIDeviceAssociation>)deviceAssociation {
    id<XICOLogging> logger = [[XICOLogger sharedLogger] createLoggerWithFacility:@"Device Association"];
    return (id<XIDeviceAssociation>)[self serviceWithCallProviderClass:[XIDADeviceAssociationRestCallProvider class]
                                                  internalClass:[XIDADeviceAssociation class]
                                                     proxyClass:[XIDeviceAssociationProxy class]
                                                         logger:logger];
} */

- (id<XIMessagingCreator>)messagingCreator {
    id<XICOLogging> logger = [[XICOLogger sharedLogger] createLoggerWithFacility:@"Messaging"];
    return (id<XIMessagingCreator>)[self serviceUsingConnectionPoolWithInternalClass:[XIMSGMessagingCreator class]
                                                                              proxyClass:[XIMessagingCreatorProxy class]
                                                                                  logger:logger];
}

@end

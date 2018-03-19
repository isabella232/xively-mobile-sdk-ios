//
//  XISessionServices.m
//  common-iOS
//
//  Created by vfabian on 15/01/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XISessionServices.h"
#import "XISessionServices+Init.h"
#import <XivelySDK/OrganizationInfo/XISessionServices+OrganizationHandler.h>
#import <XivelySDK/DeviceInfo/XISessionServices+DeviceInfo.h>
// TBD #import <XivelySDK/DeviceAssociation/XISessionServices+DeviceAssociation.h>
#import <XivelySDK/TimeSeries/XISessionServices+TimeSeries.h>
#import <XivelySDK/Messaging/XISessionServices+Messaging.h>

@interface XISessionServices () {
    XISessionServicesInternal *_internal;
}

@end

@implementation XISessionServices

- (instancetype)initWithSessionServicesInternal:(XISessionServicesInternal *)internal {
    self = [super init];
    if (self) {
        _internal = internal;
    }
    return self;
}

- (id<XIDeviceInfoList>)deviceInfoList {
    return [_internal deviceInfoList];
}

- (id<XIDeviceHandler>)deviceHandler {
    return [_internal deviceHandler];
}

- (id<XITimeSeries>)timeSeries {
    return [_internal timeSeries];
}

- (id<XIOrganizationHandler>)organizationHandler {
    return [_internal organizationHandler];
}

- (id<XIOrganizationHandler>)endUserHandler {
    return [_internal endUserHandler];
}

/* TBD - (id<XIDeviceAssociation>)deviceAssociation {
    return [_internal deviceAssociation];
} */

- (id<XIMessagingCreator>)messagingCreator {
    return [_internal messagingCreator];
}

@end

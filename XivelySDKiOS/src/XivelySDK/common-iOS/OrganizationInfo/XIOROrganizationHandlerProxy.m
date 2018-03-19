//
//  XIOROrganizationHandlerProxy.m
//  common-iOS
//
//  Created by tkorodi on 19/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import "XIOROrganizationHandlerProxy.h"
#import <XivelySDK/OrganizationInfo/XIOrganizationHandler.h>

@interface XIOROrganizationHandlerProxy () {
@private
    id<XIOrganizationHandler> _internal;
}
@end

@implementation XIOROrganizationHandlerProxy

- (XIOrganizationHandlerState)state {
    return _internal.state;
}

- (id<XIOrganizationHandlerDelegate>)delegate {
    return _internal.delegate;
}

- (void)setDelegate:(id<XIOrganizationHandlerDelegate>)delegate {
    _internal.delegate = delegate;
}

- (NSError *)error {
    return _internal.error;
}

- (instancetype)initWithInternal:(id<XIOrganizationHandler>)internal {
    self = [super init];
    if (self) {
        _internal = internal;
    }
    return self;
}

- (void)requestOrganization:(NSString*)organizationId {
    [_internal requestOrganization: organizationId];
}

- (void)listOrganizations {
    [_internal listOrganizations];
}

- (void)cancel {
    [_internal cancel];
}

@end

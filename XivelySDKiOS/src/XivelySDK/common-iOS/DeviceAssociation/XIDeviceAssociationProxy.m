//
//  XIDeviceAssociationProxy.m
//  common-iOS
//
//  Created by vfabian on 16/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIDeviceAssociationProxy.h"

@interface XIDeviceAssociationProxy () {
    @private
    id<XIDeviceAssociation> _internal;
}
@end

@implementation XIDeviceAssociationProxy

- (XIDeviceAssociationState)state {
    return _internal.state;
}

- (id<XIDeviceAssociationDelegate>)delegate {
    return _internal.delegate;
}

- (void)setDelegate:(id<XIDeviceAssociationDelegate>)delegate {
    _internal.delegate = delegate;
}

- (NSError *)error {
    return _internal.error;
}

- (instancetype)initWithInternal:(id<XIDeviceAssociation>)internal {
    self = [super init];
    if (self) {
        _internal = internal;
    }
    return self;
}

- (void)associateDeviceWithAssociationCode:(NSString *)associationCode {
    [_internal associateDeviceWithAssociationCode:associationCode];
}

- (void)cancel {
    [_internal cancel];
}

@end

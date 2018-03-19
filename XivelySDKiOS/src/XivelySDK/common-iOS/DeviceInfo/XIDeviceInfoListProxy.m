//
//  XIDeviceInfoListProxy.m
//  common-iOS
//
//  Created by vfabian on 25/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIDeviceInfoListProxy.h"
#import <XivelySDK/DeviceInfo/XIDeviceInfoList.h>

@interface XIDeviceInfoListProxy () {
@private
    id<XIDeviceInfoList> _internal;
}
@end

@implementation XIDeviceInfoListProxy

- (XIDeviceInfoListState)state {
    return _internal.state;
}

- (id<XIDeviceInfoListDelegate>)delegate {
    return _internal.delegate;
}

- (void)setDelegate:(id<XIDeviceInfoListDelegate>)delegate {
    _internal.delegate = delegate;
}

- (NSError *)error {
    return _internal.error;
}

- (instancetype)initWithInternal:(id<XIDeviceInfoList>)internal {
    self = [super init];
    if (self) {
        _internal = internal;
    }
    return self;
}

- (void)requestList {
    [_internal requestList];
}

- (void)cancel {
    [_internal cancel];
}

@end

//
//  XIDeviceHandlerProxy.m
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import "XIDIDeviceHandlerProxy.h"
#import <XivelySDK/DeviceInfo/XIDeviceHandler.h>

@interface XIDIDeviceHandlerProxy () {
@private
    id<XIDeviceHandler> _internal;
}
@end

@implementation XIDIDeviceHandlerProxy

- (XIDeviceHandlerState)state {
    return _internal.state;
}

- (id<XIDeviceHandlerDelegate>)delegate {
    return _internal.delegate;
}

- (void)setDelegate:(id<XIDeviceHandlerDelegate>)delegate {
    _internal.delegate = delegate;
}

- (NSError *)error {
    return _internal.error;
}

- (instancetype)initWithInternal:(id<XIDeviceHandler>)internal {
    self = [super init];
    if (self) {
        _internal = internal;
    }
    return self;
}

- (void)requestDevice:(NSString*)deviceId {
    [_internal requestDevice: deviceId];
}

- (void)putDevice:(XIDeviceInfo*)deviceInfo {
    [_internal putDevice: deviceInfo];
}

- (void)cancel {
    [_internal cancel];
}

@end

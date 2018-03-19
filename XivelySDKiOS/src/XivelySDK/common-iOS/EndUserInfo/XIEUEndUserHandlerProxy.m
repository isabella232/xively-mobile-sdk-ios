//
//  XIOROrganizationHandlerProxy.m
//  common-iOS
//
//  Created by tkorodi on 19/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import "XIEUEndUserHandlerProxy.h"
#import <XivelySDK/EndUserInfo/XIEndUserHandler.h>

@interface XIEUEndUserHandlerProxy () {
@private
    id<XIEndUserHandler> _internal;
}
@end

@implementation XIEUEndUserHandlerProxy

- (XIEndUserHandlerState)state {
    return _internal.state;
}

- (id<XIEndUserHandlerDelegate>)delegate {
    return _internal.delegate;
}

- (void)setDelegate:(id<XIEndUserHandlerDelegate>)delegate {
    _internal.delegate = delegate;
}

- (NSError *)error {
    return _internal.error;
}

- (instancetype)initWithInternal:(id<XIEndUserHandler>)internal {
    self = [super init];
    if (self) {
        _internal = internal;
    }
    return self;
}

- (void)requestEndUser:(NSString*)endUserId {
    [_internal requestEndUser: endUserId];
}

- (void)putEndUser:(XIEndUserInfo*)endUser {
    [_internal putEndUser: endUser];
}


- (void)cancel {
    [_internal cancel];
}

@end

//
//  XIMessagingProxy.m
//  common-iOS
//
//  Created by vfabian on 23/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIMessagingProxy.h"

@interface XIMessagingProxy () {
    @private
    id<XIMessaging> _internal;
}

@end

@implementation XIMessagingProxy

- (XIMessagingState)state {
    return _internal.state;
}

- (NSError *)finalError {
    return _internal.finalError;
}

- (instancetype)initWithInternal:(id<XIMessaging>)internal {
    self = [super init];
    if (self) {
        _internal = internal;
    }
    return self;
}

- (void)addDataListener:(id<XIMessagingDataListener>)listener {
    [_internal addDataListener:listener];
}

- (void)removeDataListener:(id<XIMessagingDataListener>)listener {
    [_internal removeDataListener:listener];
}

- (void)addStateListener:(id<XIMessagingStateListener>)listener {
    [_internal addStateListener:listener];
}

- (void)removeStateListener:(id<XIMessagingStateListener>)listener {
    [_internal removeStateListener:listener];
}

- (void)addSubscriptionListener:(id<XIMessagingSubscriptionListener>)listener {
    [_internal addSubscriptionListener:listener];
}

- (void)removeSubscriptionListener:(id<XIMessagingSubscriptionListener>)listener {
    [_internal removeSubscriptionListener:listener];
}

- (NSUInteger)publishToChannel:(NSString *)channel message:(NSData *)message qos:(XIMessagingQoS)qos {
    return [_internal publishToChannel:channel message:message qos:qos];
}

- (NSUInteger)publishToChannel:(NSString *)channel message:(NSData *)message qos:(XIMessagingQoS)qos retain:(BOOL)retain {
    return [_internal publishToChannel:channel message:message qos:qos retain:retain];
}

- (void)subscribeToChannel:(NSString *)channel qos:(XIMessagingQoS)qos {
    [_internal subscribeToChannel:channel qos:qos];
}

- (void)unsubscribeFromChannel:(NSString *)channel {
    [_internal unsubscribeFromChannel:channel];
}

- (void)close {
    [_internal close];
}

@end

//
//  XIMessagingCreatorProxy.m
//  common-iOS
//
//  Created by vfabian on 23/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIMessagingCreatorProxy.h"

@interface XIMessagingCreatorProxy () {
    @private
    id<XIMessagingCreator> _internal;
}

@end

@implementation XIMessagingCreatorProxy

- (id<XIMessaging>)resultMessaging {
    return _internal.resultMessaging;
}

- (id<XIMessagingCreatorDelegate>)messagingCreatorDelegate {
    return _internal.messagingCreatorDelegate;
}

- (void)setMessagingCreatorDelegate:(id<XIMessagingCreatorDelegate>)messagingCreatorDelegate {
    _internal.messagingCreatorDelegate = messagingCreatorDelegate;
}

- (XIServiceCreatorState)state {
    return _internal.state;
}

- (id<NSObject>)result {
    return _internal.result;
}

- (NSError *)error {
    return _internal.error;
}

- (id<NSObject>)delegate {
    return _internal.delegate;
}

- (void)setDelegate:(id<NSObject>)delegate {
    _internal.delegate = delegate;
}

- (instancetype)initWithInternal:(id<XIMessagingCreator>)internal {
    self = [super init];
    if (self) {
        _internal = internal;
    }
    return self;
}

- (void)createMessaging {
    
    [_internal createMessaging];
}


- (void)createMessagingWithCleanSession: (BOOL) cleanSession {
    
    [_internal createMessagingWithCleanSession: cleanSession];
}


- (void)createMessagingWithCleanSession: (BOOL) cleanSession lastWill: (XILastWill*) lastWill {
    
    [_internal createMessagingWithCleanSession: cleanSession lastWill: lastWill];
}

- (void)cancel {
    [_internal cancel];
}

@end

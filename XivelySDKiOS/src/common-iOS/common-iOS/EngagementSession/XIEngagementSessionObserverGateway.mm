//
//  XIEngagementSessionObserverGateway.cpp
//  common-iOS
//
//  Created by vfabian on 29/01/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIEngagementSessionGatewayImpl.h"
#include "XIEngagementSessionObserverGateway.h"

#import "NSString+StdString.h"


XIEngagementSessionObserverGateway::XIEngagementSessionObserverGateway(id<XIEngagementSessionObserverGatewayDelegate> delegate) : _delegate(delegate) {
}

XIEngagementSessionObserverGateway::~XIEngagementSessionObserverGateway() {
}

void XIEngagementSessionObserverGateway::setDelegate(id<XIEngagementSessionObserverGatewayDelegate> delegate) {
    _delegate = delegate;
}

void XIEngagementSessionObserverGateway::onSessionStarting() const {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        if ([_delegate respondsToSelector:@selector(onEngagementSessionStarting)]) {
            [_delegate onEngagementSessionStarting];
        }
    });
}

void XIEngagementSessionObserverGateway::onSessionStarted() const {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        if ([_delegate respondsToSelector:@selector(onEngagementSessionStarted)]) {
            [_delegate onEngagementSessionStarted];
        }
    });
}

void XIEngagementSessionObserverGateway::onSessionConnecting() const {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        if ([_delegate respondsToSelector:@selector(onEngagementSessionConnecting)]) {
            [_delegate onEngagementSessionConnecting];
        }
    });
}

void XIEngagementSessionObserverGateway::onSessionConnected() const {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        if ([_delegate respondsToSelector:@selector(onEngagementSessionConnected)]) {
            [_delegate onEngagementSessionConnected];
        }
    });
}

void XIEngagementSessionObserverGateway::onSessionSubscribed(const std::string& topic) const {
    
    NSString* topicString = topic.length() ? [NSString stringWithstring: topic] : @"";
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            if ([_delegate respondsToSelector:@selector(onEngagementSessionSubscribed:)]) {
                [_delegate onEngagementSessionSubscribed:topicString];
            }
        }
    });
}

void XIEngagementSessionObserverGateway::onSessionUnsubscribed(const std::string& topic) const {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            if ([_delegate respondsToSelector:@selector(onEngagementSessionSubscribed:)]) {
                NSString* topicString = [NSString stringWithstring: topic];
                [_delegate onEngagementSessionUnsubscribed:topicString];
            }
        }
    });
}

void XIEngagementSessionObserverGateway::onSessionStopping() const {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        if ([_delegate respondsToSelector:@selector(onEngagementSessionStopping)]) {
            [_delegate onEngagementSessionStopping];
        }
    });
}

void XIEngagementSessionObserverGateway::onSessionStopped() const {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        if ([_delegate respondsToSelector:@selector(onEngagementSessionStopped)]) {
            [_delegate onEngagementSessionStopped];
        }
    });
}

void XIEngagementSessionObserverGateway::onSessionError(const DisconnectReason reason) const {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        if ([_delegate respondsToSelector:@selector(onEngagementSessionError:)]) {
            [_delegate onEngagementSessionError:reason];
        }
    });
}

void XIEngagementSessionObserverGateway::onSessionSuspended() const {
    dispatch_async(dispatch_get_main_queue(), ^ {
        if ([_delegate respondsToSelector:@selector(onEngagementSessionSuspended)]) {
            [_delegate onEngagementSessionSuspended];
        }
    });
}

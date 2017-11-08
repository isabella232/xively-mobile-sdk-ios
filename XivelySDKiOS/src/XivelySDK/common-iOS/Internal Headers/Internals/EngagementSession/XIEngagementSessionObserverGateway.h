//
//  XIEngagementSessionObserverGateway.h
//  common-iOS
//
//  Created by vfabian on 29/01/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#ifndef __common_iOS__XIEngagementSessionEngagementSessionObserverGateway__
#define __common_iOS__XIEngagementSessionEngagementSessionObserverGateway__

#import <Foundation/Foundation.h>
#include <common.h>

@class XIEngagementSessionGatewayImpl;

using namespace xively::common;

@protocol XIEngagementSessionObserverGatewayDelegate <NSObject>
@optional
- (void)onEngagementSessionStarting;
- (void)onEngagementSessionStarted;

- (void)onEngagementSessionConnecting;
- (void)onEngagementSessionConnected;

- (void)onEngagementSessionSubscribed: (NSString*) topic;
- (void)onEngagementSessionUnsubscribed: (NSString*) topic;

- (void)onEngagementSessionStopping;
- (void)onEngagementSessionStopped;

- (void)onEngagementSessionError:(const DisconnectReason&)reason;

- (void)onEngagementSessionSuspended;

@end

class XIEngagementSessionObserverGateway : public xively::common::ISessionObserver {
public:
    XIEngagementSessionObserverGateway(id<XIEngagementSessionObserverGatewayDelegate> delegate);
    
    void setDelegate(id<XIEngagementSessionObserverGatewayDelegate> delegate);
    
    virtual ~XIEngagementSessionObserverGateway();
    
    virtual void onSessionStarting() const;
    
    virtual void onSessionStarted() const;
    
    virtual void onSessionConnecting() const;
    
    virtual void onSessionConnected() const;
    
    virtual void onSessionSubscribed(const std::string& topic) const;
    
    virtual void onSessionUnsubscribed(const std::string& topic) const;
    
    virtual void onSessionStopping() const;
    
    virtual void onSessionStopped() const;
    
    virtual void onSessionError(const DisconnectReason reason) const;
    
    virtual void onSessionSuspended() const;
    
protected:
    __weak id<XIEngagementSessionObserverGatewayDelegate> _delegate;
};


#endif /* defined(__common_iOS__XIEngagementSessionEngagementSessionObserverGateway__) */

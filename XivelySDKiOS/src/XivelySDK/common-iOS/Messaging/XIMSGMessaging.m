//
//  XIMSGMessaging.m
//  common-iOS
//
//  Created by vfabian on 23/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIMSGMessaging.h"
#import "NSMutableArray+nonRetaining.h"
#import "XIMessagingDataListener.h"
#import "XIMessagingStateListener.h"
#import "XIMessagingSubscriptionListener.h"
#import <XivelySDK/Messaging/XIMessagingError.h>

@interface XIMSGMessaging () <XICOConnectionListener>

@property(nonatomic, strong)NSError *finalError;

@property(nonatomic, strong)NSMutableArray *dataListeners;
@property(nonatomic, strong)NSMutableArray *stateListeners;
@property(nonatomic, strong)NSMutableArray *subscriptionListeners;

@property(nonatomic, strong)id<XICOLogging> logger;

@property(nonatomic, strong)id<XICOConnecting> connection;

@property(nonatomic, readonly)BOOL isActive;
@property(nonatomic, assign)BOOL isReleased;

@property(nonatomic, strong)XICOSessionNotifications *notifications;
@end

@implementation XIMSGMessaging

@synthesize finalError = _finalError;
@synthesize proxy = _proxy;

- (XIMessagingState)state {
    if (self.isReleased) {
        return XIMessagingStateClosed;
    }
    
    switch (self.connection.state) {
        case XICOConnectionStateInit:
            return XIMessagingStateClosed;
            break;
            
        case XICOConnectionStateConnected:
            return XIMessagingStateConnected;
            
        case XICOConnectionStateSuspended:
        case XICOConnectionStateReconnecting:
            return XIMessagingStateReconnecting;
            
        case XICOConnectionStateError:
            return XIMessagingStateError;
        
        //case XICOConnectionStateConnecting:
        default:
            assert(0);
            break;
    }
}

- (XIMessagingQoS)connectionQOSToMessaging:(XICOQOS)qos {
    switch (qos) {
        case XICOQOSAtMostOnce:
            return XIMessagingQoSAtMostOnce;
            
        case XICOQOSAtLeastOnce:
            return XIMessagingQoSAtLeastOnce;

        case XICOQOSExactlyOnce:
            assert(0);
            //return XIMessagingQoSExactlyOnce;
            
        default:
            assert(0);
    }
}

- (XICOQOS)messagingQOSToconnection:(XIMessagingQoS)qos {
    switch (qos) {
        case XIMessagingQoSAtMostOnce:
            return XICOQOSAtMostOnce;
            
        case XIMessagingQoSAtLeastOnce:
            return XICOQOSAtLeastOnce;
            
        //case XIMessagingQoSExactlyOnce:
            //return XICOQOSExactlyOnce;
            
        default:
            assert(0);
    }
}

- (BOOL)isActive {
    return !self.isReleased &&
        (self.state == XIMessagingStateConnected || self.state == XIMessagingStateReconnecting);
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                         proxy:(id<XIMessaging>)proxy
                    connection:(id<XICOConnecting>)connection
                 notifications:(XICOSessionNotifications *)notifications {
    self = [super init];
    if (self) {
        self.logger = logger;
        self.proxy = proxy;
        self.connection = connection;
        [self.connection addListener:self];
        self.dataListeners = [NSMutableArray XINonRetainingArrayWithCapacity:5];
        self.stateListeners = [NSMutableArray XINonRetainingArrayWithCapacity:5];
        self.subscriptionListeners = [NSMutableArray XINonRetainingArrayWithCapacity:5];
        self.notifications = notifications;
        
        [self.notifications.sessionNotificationCenter addObserver:self
                                                         selector:@selector(onSessionDidClose:)
                                                             name:XISessionDidCloseNotification
                                                           object:nil];
    }
    return self;
}

- (void)addDataListener:(id<XIMessagingDataListener>)listener {
    [self.dataListeners addObject:listener];
}

- (void)removeDataListener:(id<XIMessagingDataListener>)listener {
    [self.dataListeners removeObject:listener];
}

- (void)addStateListener:(id<XIMessagingStateListener>)listener {
    [self.stateListeners addObject:listener];
}

- (void)removeStateListener:(id<XIMessagingStateListener>)listener {
    [self.stateListeners removeObject:listener];
}

- (void)addSubscriptionListener:(id<XIMessagingSubscriptionListener>)listener {
    [self.subscriptionListeners addObject:listener];
}

- (void)removeSubscriptionListener:(id<XIMessagingSubscriptionListener>)listener {
    [self.subscriptionListeners removeObject:listener];
}

- (NSUInteger)publishToChannel:(NSString *)channel message:(NSData *)message qos:(XIMessagingQoS)qos {
    return [self publishToChannel:channel message:message qos:qos retain:NO];
}

- (NSUInteger)publishToChannel:(NSString *)channel message:(NSData *)message qos:(XIMessagingQoS)qos retain:(BOOL)retain {
    if (self.isActive) {
        [self.logger debug:@"Message sent"];
        [self.logger trace:@"Message sent Channel:%@ Data:%@ QoS:%d retain:%d", channel, message, qos, retain];
        return [self.connection publishData:message
                                    toTopic:channel
                                    withQos:[self messagingQOSToconnection:qos] retain:retain];
    }
    return NSUIntegerMax;
}

- (void)subscribeToChannel:(NSString *)channel qos:(XIMessagingQoS)qos {
    if (self.isActive) {
        [self.logger debug:@"Subscribe sent"];
        [self.logger trace:@"Subscribe to Channel:%@ sent", channel];
        [self.connection subscribeToTopic:channel qos:[self messagingQOSToconnection:qos]];
    }
}

- (void)unsubscribeFromChannel:(NSString *)channel {
    if (self.isActive) {
        [self.logger debug:@"Unsubscribe sent"];
        [self.logger trace:@"Unsubscribe from Channel:%@ sent", channel];
        [self.connection unsubscribeFromTopic:channel];
    }
}

- (void)close {
    if (!self.isReleased) {
        [self.logger debug:@"Messaging closed"];
        self.isReleased = YES;
        [self cleanupConnection];
        [self.dataListeners removeAllObjects];
        [self.subscriptionListeners removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            @autoreleasepool {
                for (id<XIMessagingStateListener> sl in [self.stateListeners copy]) {
                    [sl messaging:self.proxy didChangeStateTo:XIMessagingStateClosed];
                }
                [self.stateListeners removeAllObjects];
            }
        });
    }
}

- (void)cleanupConnection {
    [self.connection removeListener:self];
    [self.connection releaseConnection];
}

#pragma mark -
#pragma  mark Notifications
- (void)onSessionDidClose:(NSNotification *)notification {
    [self close];
}

#pragma mark -
#pragma  mark XICOConnectionListener
-(void) connection: (id<XICOConnecting>) connection willConnectToBroker:(NSURL*)broker {}

-(void) connection: (id<XICOConnecting>) connection didConnectedToBroker: (NSURL*) broker {
    [self.logger debug:@"Messaging connection reconnected"];
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingStateListener> sl in [self.stateListeners copy]) {
                [sl messaging:self.proxy didChangeStateTo:XIMessagingStateConnected];
            }
        }
    });
}

-(void) connection: (id<XICOConnecting>) connection willReconnectToBroker: (NSURL*) broker {
    [self.logger debug:@"Messaging is trying to reconnect"];
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingStateListener> sl in [self.stateListeners copy]) {
                [sl messaging:self.proxy didChangeStateTo:XIMessagingStateReconnecting];
            }
        }
    });
}

-(void) connection: (id<XICOConnecting>) connection willSubscribeToTopic: (NSString*) topic {}

-(void) connection: (id<XICOConnecting>) connection didSubscribeToTopic: (NSString*) topic qos:(XICOQOS)qos {
    [self.logger debug:@"Messaging subscribed"];
    [self.logger trace:@"Messaging subscribed to channel %@", topic];
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingSubscriptionListener> sl in [self.subscriptionListeners copy]) {
                [sl messaging:self.proxy didSubscribeToChannel:topic qos:[self connectionQOSToMessaging:qos]];
            }
        }
    });
}

- (void)connection:(id<XICOConnecting>)connection didFailToSubscribeToTopic:(NSString *)topic {
    [self.logger debug:@"Messaging failed to subscribe"];
    [self.logger trace:@"Did fail to subscribe %@", topic];
    NSError *error = [NSError errorWithDomain:@"Messaging" code:XIMessagingErrorSubscriptionFailed userInfo:nil];
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingSubscriptionListener> sl in [self.subscriptionListeners copy]) {
                [sl messaging:self.proxy didFailToSubscribeToChannel:topic error:error];
            }
        }
    });
}

-(void) connection: (id<XICOConnecting>) connection willUnsubscribeFromTopic: (NSString*) topic {}

-(void) connection: (id<XICOConnecting>) connection didUnsubscribeFromTopic: (NSString*) topic {
    [self.logger debug:@"Messaging unsubscribed"];
    [self.logger trace:@"Messaging subscribed to channel %@", topic];
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingSubscriptionListener> sl in [self.subscriptionListeners copy]) {
                [sl messaging:self.proxy didUnsubscribeFromChannel:topic];
            }
        }
    });
}

-(void) connection: (id<XICOConnecting>) connection didReceivePublishAckFromTopic: (NSString*) topic withData: (NSData*) data messageId: (UInt16) messageId {
    [self.logger debug:@"Messaging publish ack received"];
    [self.logger debug:@"Messaging publish ack received for message id:%d", messageId];
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingDataListener> sl in [self.dataListeners copy]) {
                if ([sl respondsToSelector:@selector(messaging:didSendDataWithId:)]) {
                    [sl messaging:self.proxy didSendDataWithId:messageId];
                }
            }
        }
    });
}

-(void) connection: (id<XICOConnecting>) connection didReceiveData: (NSData*) data fromTopic: (NSString*) topic {
    [self.logger debug:@"Messaging publish received"];
    [self.logger trace:@"Messaging publish received for channel:%@ message:%@", topic, [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingDataListener> sl in [self.dataListeners copy]) {
                [sl messaging:self.proxy didReceiveData:data onChannel:topic];
            }
        }
    });
}

-(void) connection: (id<XICOConnecting>) connection didFailToConnect: (NSError*) error {
    self.finalError = error;
    [self.logger debug:@"Messaging error: %@", error];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingStateListener> sl in [self.stateListeners copy]) {
                [sl messaging:self.proxy willEndWithError:error];
            }
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingStateListener> sl in [self.stateListeners copy]) {
                [sl messaging:self.proxy didChangeStateTo:XIMessagingStateError];
            }
        }
    });
}

-(void)connectionWasSuspended:(id<XICOConnecting>)connection {
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            for (id<XIMessagingStateListener> sl in [self.stateListeners copy]) {
                [sl messaging:self.proxy didChangeStateTo:XIMessagingStateReconnecting];
            }
        }
    });
}

#pragma mark -
#pragma  mark Memory management
- (void)dealloc {
    [self.notifications.sessionNotificationCenter removeObserver:self];
    [self cleanupConnection];
}



@end

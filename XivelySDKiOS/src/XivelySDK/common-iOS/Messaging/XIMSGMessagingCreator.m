//
//  XIMSGMessagingCreator.m
//  common-iOS
//
//  Created by vfabian on 23/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIMSGMessagingCreator.h"
#import "XIMSGMessaging.h"
#import "XIMessagingProxy.h"

typedef NS_ENUM(NSInteger, XIMSGMessagingEvent) {
    XIMSGMessagingEventCreate     = 1,
    XIMSGMessagingEventCancel,
    XIMSGMessagingEventCreateSuccess,
    XIMSGMessagingEventCreateFail
};

@interface XIMSGMessagingCreator () <XICOConnectionPoolDelegate>
@property(strong, nonatomic) XICOFiniteStateMachine* fsm;
@property(nonatomic, strong)id<XICOLogging> logger;

@property(nonatomic, strong)id<XIMessaging> resultMessaging;
@property(nonatomic, strong)NSError *error;

@property(nonatomic, strong)id<XICOConnectionPooling> connectionPool;
@property(nonatomic, strong)id<XICOConnectionPoolCancelable> connectionPoolCancelable;

@property(nonatomic, strong)XICOSessionNotifications *notifications;
@property(nonatomic, strong)NSString* jwt;
@end

@implementation XIMSGMessagingCreator

@synthesize proxy = _proxy;
@synthesize resultMessaging = _resultMessaging;
@synthesize messagingCreatorDelegate = _messagingCreatorDelegate;
@synthesize error = _error;
@synthesize jwt = _jwt;

- (XIServiceCreatorState)state {
    return (XIServiceCreatorState)self.fsm.state;
}

- (id<NSObject>)result {
    return self.resultMessaging;
}

- (id<NSObject>)delegate {
    return self.messagingCreatorDelegate;
}

- (void)setDelegate:(id<NSObject>)delegate {
    self.messagingCreatorDelegate = (id<XIMessagingCreatorDelegate>)delegate;
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                         proxy:(id<XIMessagingCreator>)proxy
                           jwt:(NSString*)jwt
                connectionPool:(id<XICOConnectionPooling>)pool
                 notifications:(XICOSessionNotifications *)notifications{
    self = [super init];
    if (self) {
        self.proxy = proxy;
        self.jwt = jwt;
        self.logger = logger;
        self.connectionPool = pool;
        self.notifications = notifications;
        
        self.fsm = [[XICOFiniteStateMachine alloc] initWithInitialState:XIServiceCreatorStateIdle];
        
        //Idle
        [self.fsm addTransitionWithState: XIServiceCreatorStateIdle
                                   event: XIMSGMessagingEventCreate
                                  object: self
                                selector: @selector(onIdleCreate:)];
        
        [self.fsm addTransitionWithState: XIServiceCreatorStateIdle
                                   event: XIMSGMessagingEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        //Creating
        [self.fsm addTransitionWithState: XIServiceCreatorStateCreating
                                   event: XIMSGMessagingEventCancel
                                  object: self
                                selector: @selector(onCreatingCancel:)];
        
        [self.fsm addTransitionWithState: XIServiceCreatorStateCreating
                                   event: XIMSGMessagingEventCreateSuccess
                                  object: self
                                selector: @selector(onCreatingCreateSuccess:)];
        
        [self.fsm addTransitionWithState: XIServiceCreatorStateCreating
                                   event: XIMSGMessagingEventCreateFail
                                  object: self
                                selector: @selector(onCreatingCreateFail:)];
        
        //created
        [self.fsm addTransitionWithState: XIServiceCreatorStateCreated
                                   event: XIMSGMessagingEventCancel
                                  object: self
                                selector: @selector(onEndedCancel:)];
        //error
        [self.fsm addTransitionWithState: XIServiceCreatorStateError
                                   event: XIMSGMessagingEventCancel
                                  object: self
                                selector: @selector(onEndedCancel:)];
        
        [self.notifications.sessionNotificationCenter addObserver:self
                                                         selector:@selector(onSessionDidClose:)
                                                             name:XISessionDidCloseNotification
                                                           object:nil];
    }
    return self;
}

- (void)createMessaging {
    
    [self createMessagingWithCleanSession: YES];
}

- (void)createMessagingWithCleanSession: (BOOL) cleanSession {
    
    [self createMessagingWithCleanSession: cleanSession lastWill: nil];
}

- (void)createMessagingWithCleanSession: (BOOL) cleanSession lastWill: (XILastWill*) lastWill {
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    params[@"cleanSession"] = @(cleanSession);
    if (lastWill) {
        params[@"lastWill"] = lastWill;
    }
    
    [self.fsm doEvent: XIMSGMessagingEventCreate withObject: params];
}

- (void)cancel {
    [self.fsm doEvent:XIMSGMessagingEventCancel];
}

#pragma mark -
#pragma  mark Notifications
- (void)onSessionDidClose:(NSNotification *)notification {
    [self cancel];
}

#pragma mark -
#pragma mark FSM

#pragma mark Idle state
- (NSInteger)onIdleCreate:(NSDictionary*)params {
    [self.logger debug:@"Create Messaging requested"];
    
    BOOL cleanSession = [params[@"cleanSession"] boolValue];
    XILastWill* lastWill = params[@"lastWill"];
    
    self.connectionPoolCancelable = [self.connectionPool requestConnectionWithCleanSession: cleanSession
                                                                                  lastWill: lastWill
                                                                                       jwt: self.jwt
                                                                                  delegate: self];
    return XIServiceCreatorStateCreating;
}

- (NSInteger)onIdleCancel:(id)object {
    [self.logger debug:@"Idle Messaging Canceled"];
    return XIServiceCreatorStateCanceled;
}

#pragma mark Creating state
- (NSInteger)onCreatingCancel:(id)object {
    [self.logger debug:@"Creating Messaging Canceled"];
    [self.connectionPoolCancelable cancel];
    return XIServiceCreatorStateCanceled;
}

- (NSInteger)onCreatingCreateSuccess:(id<XICOConnecting>)connection {
    [self.logger debug:@"Connection received"];
    
    XIMSGMessaging *messaging = [[XIMSGMessaging alloc] initWithLogger:self.logger
                                                                           proxy:nil
                                                                      connection:connection
                                                                   notifications:self.notifications];
    
    XIMessagingProxy *proxy = [[XIMessagingProxy alloc] initWithInternal:messaging];
    messaging.proxy = proxy;
    
    self.resultMessaging = proxy;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            if (self.state == XIServiceCreatorStateCreated) {
                [self.messagingCreatorDelegate messagingCreator:self.proxy didCreateMessaging:self.resultMessaging];
            }
        }
    });
    
    return XIServiceCreatorStateCreated;
}

- (NSInteger)onCreatingCreateFail:(NSError *)error {
    [self.logger debug:@"Connection receive failed"];
    self.error = error;
    dispatch_async(dispatch_get_main_queue(), ^ {
        @autoreleasepool {
            if (self.state == XIServiceCreatorStateError) {
                [self.messagingCreatorDelegate messagingCreator:self.proxy didFailToCreateMessagingWithError:error];
            }
        }
    });
    
    return XIServiceCreatorStateError;
}

#pragma mark Finished states

- (NSInteger)onEndedCancel:(id)object {
    [self.logger debug:@"Created or error state canceled"];
    return XIServiceCreatorStateCanceled;
}

#pragma mark -
#pragma mark XICOConnectionPoolDelegate
- (void)connectionPool:(id<XICOConnectionPooling>)connectionPool didCreateConnection:(id<XICOConnecting>)connection {
    [self.fsm doEvent:XIMSGMessagingEventCreateSuccess withObject:connection];
}

- (void)connectionPool:(id<XICOConnectionPooling>)connectionPool didFailToCreateConnection:(NSError*)error {
    [self.fsm doEvent:XIMSGMessagingEventCreateFail withObject:error];
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    [self.notifications.sessionNotificationCenter removeObserver:self];
    [self.connectionPoolCancelable cancel];
}

@end


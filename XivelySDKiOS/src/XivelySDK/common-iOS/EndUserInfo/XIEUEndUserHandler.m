//
//  XIOREndUserHandler.m
//  common-iOS
//
//  Created by tkorodi on 18/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import "XIEUEndUserHandler.h"
#import "XIAccess.h"

typedef NS_ENUM(NSUInteger, XIEndUserHandlerHiddenState) {
    XIEndUserHandlerStateSuspendedWhileRunning = (XIEndUserHandlerStateIdle - 1),
    XIEndUserHandlerStateSuspendedWhileIdle = (XIEndUserHandlerStateIdle - 2),
    XIEndUserHandlerStateInitialRequest = (XIEndUserHandlerStateIdle - 3),
    XIEndUserHandlerStateExtendedRequest = (XIEndUserHandlerStateIdle - 4),
};

typedef NS_ENUM(NSInteger, XIDIDeviceInfoListEvent) {
    XIEndUserHandlerGetEventRequest     = 1,
    XIEndUserHandlerPutEventRequest,
    XIEndUserHandlerGetListEventRequest,
    XIEndUserHandlerEventCancel,
    XIEndUserHandlerEventDeviceInfosReceived,
    XIEndUserHandlerEventError,
    XIEndUserHandlerEventSuspend,
    XIEndUserHandlerEventResume,
};

@interface XIEUEndUserHandler ()

@property(strong, nonatomic) XICOFiniteStateMachine* fsm;
@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIEndUserInfoCallProvider> callProvider;
@property(strong, nonatomic) NSMutableArray *runningDeviceCalls;
@property(strong, nonatomic) XIAccess* access;

@property(nonatomic, strong)NSError *error;
@property(nonatomic, strong)NSString *associationCode;
@property(nonatomic, strong)XICOSessionNotifications *notifications;
@property(nonatomic, strong)XIServicesConfig *servicesConfig;

@property(nonatomic, strong)NSMutableArray *aggregatedEndUserList;

@end

@implementation XIEUEndUserHandler

@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize proxy = _proxy;

- (XIEndUserHandlerState)state {
    switch (self.fsm.state) {
        case XIEndUserHandlerStateSuspendedWhileRunning:
            return XIEndUserHandlerStateRunning;
            break;
            
        case XIEndUserHandlerStateSuspendedWhileIdle:
            return XIEndUserHandlerStateIdle;
            break;
            
        case XIEndUserHandlerStateInitialRequest:
            return XIEndUserHandlerStateRunning;
            break;
            
        case XIEndUserHandlerStateExtendedRequest:
            return XIEndUserHandlerStateRunning;
            break;
            
        case XIEndUserHandlerStateRunning:
            assert(0);
            break;
            
        default:
            return (XIEndUserHandlerState)self.fsm.state;
            break;
    }
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                  callProvider:(id<XIEndUserInfoCallProvider>)callProvider
                         proxy:(id<XIEndUserHandler>)proxy
                        access:(XIAccess *)access
                 notifications:(XICOSessionNotifications *)notifications
                        config:(XIServicesConfig *)serviceConfig {
    assert(callProvider);
    assert(access);
    assert(notifications);
    if ((self = [super init])) {
        
        self.fsm = [[XICOFiniteStateMachine alloc] initWithInitialState:XIEndUserHandlerStateIdle];
        
        // Idle
        [self.fsm addTransitionWithState: XIEndUserHandlerStateIdle
                                   event: XIEndUserHandlerGetEventRequest
                                  object: self
                                selector: @selector(onInitialGetRequest:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateIdle
                                   event: XIEndUserHandlerPutEventRequest
                                  object: self
                                selector: @selector(onInitialPutRequest:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateIdle
                                   event: XIEndUserHandlerEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateIdle
                                   event: XIEndUserHandlerEventSuspend
                                  object: self
                                selector: @selector(onIdleSuspend:)];
        //Initial Request
        [self.fsm addTransitionWithState: XIEndUserHandlerStateInitialRequest
                                   event: XIEndUserHandlerEventCancel
                                  object: self
                                selector: @selector(onRunningCancel:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateInitialRequest
                                   event: XIEndUserHandlerEventDeviceInfosReceived
                                  object: self
                                selector: @selector(onInitialRequestReceived:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateInitialRequest
                                   event: XIEndUserHandlerEventError
                                  object: self
                                selector: @selector(onRunningError:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateInitialRequest
                                   event: XIEndUserHandlerEventSuspend
                                  object: self
                                selector: @selector(onRunningSuspend:)];
        
        //XIDeviceHandlerStateExtendedRequest
        [self.fsm addTransitionWithState: XIEndUserHandlerStateExtendedRequest
                                   event: XIEndUserHandlerEventCancel
                                  object: self
                                selector: @selector(onRunningCancel:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateExtendedRequest
                                   event: XIEndUserHandlerEventDeviceInfosReceived
                                  object: self
                                selector: @selector(onAggregatedRequestReceived:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateExtendedRequest
                                   event: XIEndUserHandlerEventError
                                  object: self
                                selector: @selector(onRunningError:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateExtendedRequest
                                   event: XIEndUserHandlerEventSuspend
                                  object: self
                                selector: @selector(onRunningSuspend:)];
        
        //XIDeviceHandlerStateSuspendedWhileRunning
        [self.fsm addTransitionWithState: XIEndUserHandlerStateSuspendedWhileRunning
                                   event: XIEndUserHandlerEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateSuspendedWhileRunning
                                   event: XIEndUserHandlerEventResume
                                  object: self
                                selector: @selector(onInitialGetRequest:)];
        
        //XIDeviceHandlerStateSuspendedWhileIdle
        [self.fsm addTransitionWithState: XIEndUserHandlerStateSuspendedWhileIdle
                                   event: XIEndUserHandlerGetEventRequest
                                  object: self
                                selector: @selector(onSuspendedRequest:)];

        [self.fsm addTransitionWithState: XIEndUserHandlerStateSuspendedWhileIdle
                                   event: XIEndUserHandlerPutEventRequest
                                  object: self
                                selector: @selector(onSuspendedRequest:)];

        [self.fsm addTransitionWithState: XIEndUserHandlerStateSuspendedWhileIdle
                                   event: XIEndUserHandlerEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIEndUserHandlerStateSuspendedWhileIdle
                                   event: XIEndUserHandlerEventResume
                                  object: self
                                selector: @selector(onIdleSuspendedResume:)];
        
        //        //XIDeviceInfoListStateEnded
        //        [self.fsm addTransitionWithState: XIDeviceInfoListStateEnded
        //                                   event: XIDeviceHandlerEventCancel
        //                                  object: self
        //                                selector: @selector(onIdleCancel:)];
        //
        //        //XIDeviceInfoListStateError
        //        [self.fsm addTransitionWithState: XIDeviceInfoListStateError
        //                                   event: XIDeviceHandlerEventCancel
        //                                  object: self
        //                                selector: @selector(onIdleCancel:)];
        
        self.log = logger;
        self.callProvider = callProvider;
        self.proxy = proxy;
        self.access = access;
        self.notifications = notifications;
        self.aggregatedEndUserList = [NSMutableArray array];
        self.runningDeviceCalls = [NSMutableArray array];
        self.servicesConfig = serviceConfig;
        
        [self.notifications.sessionNotificationCenter addObserver:self
                                                         selector:@selector(onSessionDidSuspend:)
                                                             name:XISessionDidSuspendNotification
                                                           object:nil];
        
        [self.notifications.sessionNotificationCenter addObserver:self
                                                         selector:@selector(onSessionDidResume:)
                                                             name:XISessionDidResumeNotification
                                                           object:nil];
        
        [self.notifications.sessionNotificationCenter addObserver:self
                                                         selector:@selector(onSessionDidClose:)
                                                             name:XISessionDidCloseNotification
                                                           object:nil];
    }
    
    return self;
    
}
#pragma mark -
#pragma mark State machine
- (NSInteger)onInitialGetRequest:(NSObject *)obj {
    [_log debug: @"Initial GET Request object"];
    [self.aggregatedEndUserList removeAllObjects];
    [self.runningDeviceCalls removeAllObjects];
    
    id<XIEndUserInfoCall> call = [self.callProvider endUserInfoCall];
    call.delegate = self;
    NSString* endUserId = (NSString *)obj;
    [call getRequestWithEndUserId:endUserId];
    [self.runningDeviceCalls addObject:call];
    
    return XIEndUserHandlerStateInitialRequest;
}

- (NSInteger)onInitialPutRequest:(NSObject *)obj {
    [_log debug: @"Initial PUT Request object"];
    [self.aggregatedEndUserList removeAllObjects];
    [self.runningDeviceCalls removeAllObjects];
    
    id<XIEndUserInfoCall> call = [self.callProvider endUserInfoCall];
    call.delegate = self;
    XIEndUserInfo* endUserInfo = (XIEndUserInfo *)obj;
    [call putRequestWithEndUser:endUserInfo];
    [self.runningDeviceCalls addObject:call];
    
    return XIEndUserHandlerStateInitialRequest;
}

- (NSInteger)onIdleSuspend:(NSObject *)obj {
    [_log debug: @"Initial State canceled"];
    return XIEndUserHandlerStateSuspendedWhileIdle;
}

- (NSInteger)onIdleCancel:(NSObject *)obj {
    [_log debug: @"Initial State canceled"];
    return XIEndUserHandlerStateEnded;
}

- (NSInteger)onRunningCancel:(NSObject *)obj {
    [_log debug: @"Running canceled"];
    
    [self cancelAllRunningCallsAndClearLists];
    
    return XIEndUserHandlerStateCanceled;
}

- (NSInteger)onAggregatedRequestReceived: (NSObject*) obj {
    
    return XIEndUserHandlerStateExtendedRequest;
}

- (NSInteger)onInitialRequestReceived:(NSDictionary *)parameters {
    XIEndUserInfo *endUserInfo = parameters[@"endUserInfo"];
    
    [self.runningDeviceCalls removeAllObjects];
    
    if (endUserInfo) {
        [self notifyOnEndUserInfoWasReceived:endUserInfo];
    }
    return XIEndUserHandlerStateEnded;
}

- (NSInteger)onRunningError:(NSDictionary *)parameters {
    NSError *error = parameters[@"error"];
    [self cancelAllRunningCallsAndClearLists];
    [self notifyOnEndUserHandlerError:error];
    
    return XIEndUserHandlerStateError;
}

- (NSInteger)onRunningSuspend:(id)object {
    [self cancelAllRunningCallsAndClearLists];
    return XIEndUserHandlerStateSuspendedWhileRunning;
}

- (NSInteger)onSuspendedRequest:(id)object {
    return XIEndUserHandlerStateSuspendedWhileRunning;
}

- (NSInteger)onIdleSuspendedResume:(id)object {
    return XIEndUserHandlerStateIdle;
}

#pragma mark -
#pragma mark Privates
- (void)cancelAllRunningCallsAndClearLists {
    for (id<XIEndUserInfoCall> call in self.runningDeviceCalls) {
        call.delegate = nil;
        [call cancel];
    }
    
    [self.aggregatedEndUserList removeAllObjects];
    [self.runningDeviceCalls removeAllObjects];
}

- (void)notifyOnEndUserInfoWasReceived:(XIEndUserInfo *)endUserInfo {
    __weak XIEUEndUserHandler* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XIEndUserHandlerStateEnded) {
            [weakSelf.delegate endUserHandler:weakSelf didReceiveEndUserInfo:endUserInfo];
        }
    }});
}

- (void)notifyOnEndUserHandlerError:(NSError *)error {
    __weak XIEUEndUserHandler* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XIEndUserHandlerStateError) {
            weakSelf.error = error;
            [weakSelf.delegate endUserHandler:weakSelf.proxy didFailWithError:error];
        }
    }});
}

#pragma mark -
#pragma mark XIDeviceInfoCallDelegate
- (void)endUserInfoCall:(id<XIEndUserInfoCall>)endUserInfoCall didSucceedWithEndUserInfo:(XIEndUserInfo *)endUserInfo {
    NSDictionary *dict = @{
                           @"endUserInfoCall" : endUserInfoCall,
                           @"endUserInfo" : endUserInfo
                           };
    [self.fsm doEvent:XIEndUserHandlerEventDeviceInfosReceived withObject:dict];
}

- (void)endUserInfoCall:(id<XIEndUserInfoCall>)endUserInfoCall didFailWithError:(NSError *)error {
    NSDictionary *dict = @{
                           @"endUserInfoCall" : endUserInfoCall,
                           @"error" : error,
                           };
    [self.fsm doEvent:XIEndUserHandlerEventError withObject:dict];
}

#pragma mark -
#pragma mark Public calls

- (void)requestEndUser:(NSString *)endUserId {
    [self.fsm doEvent:XIEndUserHandlerGetEventRequest withObject:endUserId];
}

- (void)putEndUser:(XIEndUserInfo *)endUser {
    [self.fsm doEvent:XIEndUserHandlerPutEventRequest withObject:endUser];
}

- (void)cancel {
    [self.fsm doEvent:XIEndUserHandlerEventCancel];
}

#pragma mark -
#pragma mark Notifications
- (void)onSessionDidSuspend:(NSNotification *)notification {
    [self.fsm doEvent:XIEndUserHandlerEventSuspend];
}

- (void)onSessionDidResume:(NSNotification *)notification {
    [self.fsm doEvent:XIEndUserHandlerEventResume];
}

- (void)onSessionDidClose:(NSNotification *)notification {
    [self.fsm doEvent:XIEndUserHandlerEventCancel];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    [self.notifications.sessionNotificationCenter removeObserver:self];
}

@end

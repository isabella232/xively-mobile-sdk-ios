//
//  XIDIDeviceInfoList.m
//  common-iOS
//
//  Copyright (c) 2016 LogMeIn Inc. All rights reserved.
//

#import "XIDIDeviceHandler.h"
#import "XIAccess.h"

typedef NS_ENUM(NSUInteger, XIDeviceHandlerHiddenState) {
    XIDeviceHandlerStateSuspendedWhileRunning = (XIDeviceHandlerStateIdle - 1),
    XIDeviceHandlerStateSuspendedWhileIdle = (XIDeviceHandlerStateIdle - 2),
    XIDeviceHandlerStateInitialRequest = (XIDeviceHandlerStateIdle - 3),
    XIDeviceHandlerStateExtendedRequest = (XIDeviceHandlerStateIdle - 4),
};

typedef NS_ENUM(NSInteger, XIDIDeviceInfoListEvent) {
    XIDeviceHandlerGetEventRequest     = 1,
    XIDeviceHandlerPutEventRequest,
    XIDeviceHandlerEventCancel,
    XIDeviceHandlerEventDeviceInfosReceived,
    XIDeviceHandlerEventError,
    XIDeviceHandlerEventSuspend,
    XIDeviceHandlerEventResume,
};

@interface XIDIDeviceHandler ()

@property(strong, nonatomic) XICOFiniteStateMachine* fsm;
@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIDeviceInfoCallProvider> callProvider;
@property(strong, nonatomic) NSMutableArray *runningDeviceCalls;
@property(strong, nonatomic) XIAccess* access;

@property(nonatomic, strong)NSError *error;
@property(nonatomic, strong)NSString *associationCode;
@property(nonatomic, strong)XICOSessionNotifications *notifications;
@property(nonatomic, strong)XIServicesConfig *servicesConfig;

@property(nonatomic, strong)NSMutableArray *aggregatedDeviceList;

@end

@implementation XIDIDeviceHandler

@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize proxy = _proxy;

- (XIDeviceHandlerState)state {
    switch (self.fsm.state) {
        case XIDeviceHandlerStateSuspendedWhileRunning:
            return XIDeviceHandlerStateRunning;
            break;
            
        case XIDeviceHandlerStateSuspendedWhileIdle:
            return XIDeviceHandlerStateIdle;
            break;
            
        case XIDeviceHandlerStateInitialRequest:
            return XIDeviceHandlerStateRunning;
            break;
            
        case XIDeviceHandlerStateExtendedRequest:
            return XIDeviceHandlerStateRunning;
            break;
            
        case XIDeviceHandlerStateRunning:
            assert(0);
            break;
            
        default:
            return (XIDeviceHandlerState)self.fsm.state;
            break;
    }
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                  callProvider:(id<XIDeviceInfoCallProvider>)callProvider
                         proxy:(id<XIDeviceHandler>)proxy
                        access:(XIAccess *)access
                 notifications:(XICOSessionNotifications *)notifications
                        config:(XIServicesConfig *)serviceConfig {
    assert(callProvider);
    assert(access);
    assert(notifications);
    if ((self = [super init])) {
        
        self.fsm = [[XICOFiniteStateMachine alloc] initWithInitialState:XIDeviceHandlerStateIdle];
        
        // Idle
        [self.fsm addTransitionWithState: XIDeviceHandlerStateIdle
                                   event: XIDeviceHandlerGetEventRequest
                                  object: self
                                selector: @selector(onInitialGetRequest:)];

        [self.fsm addTransitionWithState: XIDeviceHandlerStateIdle
                                   event: XIDeviceHandlerPutEventRequest
                                  object: self
                                selector: @selector(onInitialPutRequest:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateIdle
                                   event: XIDeviceHandlerEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateIdle
                                   event: XIDeviceHandlerEventSuspend
                                  object: self
                                selector: @selector(onIdleSuspend:)];
        //Initial Request
        [self.fsm addTransitionWithState: XIDeviceHandlerStateInitialRequest
                                   event: XIDeviceHandlerEventCancel
                                  object: self
                                selector: @selector(onRunningCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateInitialRequest
                                   event: XIDeviceHandlerEventDeviceInfosReceived
                                  object: self
                                selector: @selector(onInitialRequestReceived:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateInitialRequest
                                   event: XIDeviceHandlerEventError
                                  object: self
                                selector: @selector(onRunningError:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateInitialRequest
                                   event: XIDeviceHandlerEventSuspend
                                  object: self
                                selector: @selector(onRunningSuspend:)];
        
        //XIDeviceHandlerStateExtendedRequest
        [self.fsm addTransitionWithState: XIDeviceHandlerStateExtendedRequest
                                   event: XIDeviceHandlerEventCancel
                                  object: self
                                selector: @selector(onRunningCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateExtendedRequest
                                   event: XIDeviceHandlerEventDeviceInfosReceived
                                  object: self
                                selector: @selector(onAggregatedRequestReceived:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateExtendedRequest
                                   event: XIDeviceHandlerEventError
                                  object: self
                                selector: @selector(onRunningError:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateExtendedRequest
                                   event: XIDeviceHandlerEventSuspend
                                  object: self
                                selector: @selector(onRunningSuspend:)];
        
        //XIDeviceHandlerStateSuspendedWhileRunning
        [self.fsm addTransitionWithState: XIDeviceHandlerStateSuspendedWhileRunning
                                   event: XIDeviceHandlerEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateSuspendedWhileRunning
                                   event: XIDeviceHandlerEventResume
                                  object: self
                                selector: @selector(onInitialGetRequest:)];
        
        //XIDeviceHandlerStateSuspendedWhileIdle
        [self.fsm addTransitionWithState: XIDeviceHandlerStateSuspendedWhileIdle
                                   event: XIDeviceHandlerGetEventRequest
                                  object: self
                                selector: @selector(onSuspendedRequest:)];

        [self.fsm addTransitionWithState: XIDeviceHandlerStateSuspendedWhileIdle
                                   event: XIDeviceHandlerPutEventRequest
                                  object: self
                                selector: @selector(onSuspendedRequest:)];

        [self.fsm addTransitionWithState: XIDeviceHandlerStateSuspendedWhileIdle
                                   event: XIDeviceHandlerEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceHandlerStateSuspendedWhileIdle
                                   event: XIDeviceHandlerEventResume
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
        self.aggregatedDeviceList = [NSMutableArray array];
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
    [_log debug: @"Initial Request Listing"];
    [self.aggregatedDeviceList removeAllObjects];
    [self.runningDeviceCalls removeAllObjects];
    
    id<XIDeviceInfoCall> call = [self.callProvider deviceInfoCall];
    call.delegate = self;
    [call getRequestWithAccountId:self.access.accountId
                         deviceId:(NSString*)obj];
    [self.runningDeviceCalls addObject:call];
    
    return XIDeviceHandlerStateInitialRequest;
}

- (NSInteger)onInitialPutRequest:(NSObject *)obj {
    [_log debug: @"Initial Request Listing"];
    [self.aggregatedDeviceList removeAllObjects];
    [self.runningDeviceCalls removeAllObjects];
    
    id<XIDeviceInfoCall> call = [self.callProvider deviceInfoCall];
    call.delegate = self;
    [call putRequestWithDeviceInfo:(XIDeviceInfo *)obj];
    [self.runningDeviceCalls addObject:call];
    
    return XIDeviceHandlerStateInitialRequest;
}


- (NSInteger)onIdleSuspend:(NSObject *)obj {
    [_log debug: @"Initial State canceled"];
    return XIDeviceHandlerStateSuspendedWhileIdle;
}

- (NSInteger)onIdleCancel:(NSObject *)obj {
    [_log debug: @"Initial State canceled"];
    return XIDeviceHandlerStateEnded;
}

- (NSInteger)onRunningCancel:(NSObject *)obj {
    [_log debug: @"Running canceled"];
    
    [self cancelAllRunningCallsAndClearLists];
    
    return XIDeviceHandlerStateCanceled;
}

- (NSInteger)onInitialRequestReceived:(NSDictionary *)parameters {
    XIDeviceInfo *deviceInfo = parameters[@"deviceInfo"];
    
    [self.runningDeviceCalls removeAllObjects];
    
        [self notifyOnDeviceInfoWasReceived:deviceInfo];
        return XIDeviceHandlerStateEnded;
}

- (NSInteger)onRunningError:(NSDictionary *)parameters {
    NSError *error = parameters[@"error"];
    [self cancelAllRunningCallsAndClearLists];
    [self notifyOnDeviceInfoListError:error];
    
    return XIDeviceHandlerStateError;
}

- (NSInteger)onRunningSuspend:(id)object {
    [self cancelAllRunningCallsAndClearLists];
    return XIDeviceHandlerStateSuspendedWhileRunning;
}

- (NSInteger)onAggregatedRequestReceived:(NSDictionary *)parameters {
    NSArray *deviceInfoList __unused = parameters[@"deviceInfoList"];
    id<XIDeviceInfoCall> deviceInfoCall __unused = parameters[@"deviceInfoCall"];
    
    NSLog(@"On aggregated request received");
    
    //TODO what if the list changes while listing
    
//    if ([self.runningDeviceListCalls containsObject:deviceInfoCall]) {
//        [self.runningDeviceListCalls removeObject:deviceInfoCall];
//        
//        // Do we need this?
//        [self.aggregatedDeviceList addObjectsFromArray:deviceInfoList];
//        
//        if (self.runningDeviceListCalls.count == 0) {
//            [self notifyOnDeviceInfoListWasReceived:self.aggregatedDeviceList];
//            return XIDeviceInfoListStateEnded;
//        }
//    }
    
    return self.fsm.state;
}

- (NSInteger)onSuspendedRequest:(id)object {
    return XIDeviceHandlerStateSuspendedWhileRunning;
}

- (NSInteger)onIdleSuspendedResume:(id)object {
    return XIDeviceHandlerStateIdle;
}

#pragma mark -
#pragma mark Privates
- (void)cancelAllRunningCallsAndClearLists {
    for (id<XIDeviceInfoCall> call in self.runningDeviceCalls) {
        call.delegate = nil;
        [call cancel];
    }
    
    [self.aggregatedDeviceList removeAllObjects];
    [self.runningDeviceCalls removeAllObjects];
}

- (void)notifyOnDeviceInfoWasReceived:(XIDeviceInfo *)deviceInfo {
    __weak XIDIDeviceHandler* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XIDeviceHandlerStateEnded) {
            [weakSelf.delegate deviceHandler:weakSelf didReceiveDeviceInfo:deviceInfo];
        }
    }});
}

- (void)notifyOnDeviceInfoListError:(NSError *)error {
    __weak XIDIDeviceHandler* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XIDeviceHandlerStateError) {
            weakSelf.error = error;
            [weakSelf.delegate deviceHandler:weakSelf.proxy didFailWithError:error];
        }
    }});
}

#pragma mark -
#pragma mark XIDeviceInfoCallDelegate
- (void)deviceInfoCall:(id<XIDeviceInfoCall>)deviceInfoCall didSucceedWithDeviceInfo:(XIDeviceInfo *)deviceInfo {
    NSDictionary *dict = @{
                           @"deviceInfoCall" : deviceInfoCall,
                           @"deviceInfo" : deviceInfo
                           };
    [self.fsm doEvent:XIDeviceHandlerEventDeviceInfosReceived withObject:dict];
}

- (void)deviceInfoCall:(id<XIDeviceInfoCall>)deviceInfoCall didFailWithError:(NSError *)error {
    NSDictionary *dict = @{
                           @"deviceInfoCall" : deviceInfoCall,
                           @"error" : error,
                           };
    [self.fsm doEvent:XIDeviceHandlerEventError withObject:dict];
}

#pragma mark -
#pragma mark Public calls

- (void)requestDevice:(NSString*)deviceId {
    [self.fsm doEvent:XIDeviceHandlerGetEventRequest withObject:deviceId];
}

- (void)putDevice:(XIDeviceInfo*)deviceInfo {
    [self.fsm doEvent:XIDeviceHandlerPutEventRequest withObject:deviceInfo];
}

- (void)cancel {
    [self.fsm doEvent:XIDeviceHandlerEventCancel];
}

#pragma mark -
#pragma mark Notifications
- (void)onSessionDidSuspend:(NSNotification *)notification {
    [self.fsm doEvent:XIDeviceHandlerEventSuspend];
}

- (void)onSessionDidResume:(NSNotification *)notification {
    [self.fsm doEvent:XIDeviceHandlerEventResume];
}

- (void)onSessionDidClose:(NSNotification *)notification {
    [self.fsm doEvent:XIDeviceHandlerEventCancel];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    [self.notifications.sessionNotificationCenter removeObserver:self];
}

@end

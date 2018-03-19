//
//  XIOROrganizationHandler.m
//  common-iOS
//
//  Created by tkorodi on 18/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import "XIOROrganizationHandler.h"
#import "XIAccess.h"

typedef NS_ENUM(NSUInteger, XIOrganizationHandlerHiddenState) {
    XIOrganizationHandlerStateSuspendedWhileRunning = (XIOrganizationHandlerStateIdle - 1),
    XIOrganizationHandlerStateSuspendedWhileIdle = (XIOrganizationHandlerStateIdle - 2),
    XIOrganizationHandlerStateInitialRequest = (XIOrganizationHandlerStateIdle - 3),
    XIOrganizationHandlerStateExtendedRequest = (XIOrganizationHandlerStateIdle - 4),
};

typedef NS_ENUM(NSInteger, XIDIDeviceInfoListEvent) {
    XIOrganizationHandlerGetEventRequest     = 1,
    XIOrganizationHandlerGetListEventRequest,
    XIOrganizationHandlerEventCancel,
    XIOrganizationHandlerEventDeviceInfosReceived,
    XIOrganizationHandlerEventError,
    XIOrganizationHandlerEventSuspend,
    XIOrganizationHandlerEventResume,
};

@interface XIOROrganizationHandler ()

@property(strong, nonatomic) XICOFiniteStateMachine* fsm;
@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIOrganizationInfoCallProvider> callProvider;
@property(strong, nonatomic) NSMutableArray *runningDeviceCalls;
@property(strong, nonatomic) XIAccess* access;

@property(nonatomic, strong)NSError *error;
@property(nonatomic, strong)NSString *associationCode;
@property(nonatomic, strong)XICOSessionNotifications *notifications;
@property(nonatomic, strong)XIServicesConfig *servicesConfig;

@property(nonatomic, strong)NSMutableArray *aggregatedOrganizationList;

@end

@implementation XIOROrganizationHandler

@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize proxy = _proxy;

- (XIOrganizationHandlerState)state {
    switch (self.fsm.state) {
        case XIOrganizationHandlerStateSuspendedWhileRunning:
            return XIOrganizationHandlerStateRunning;
            break;
            
        case XIOrganizationHandlerStateSuspendedWhileIdle:
            return XIOrganizationHandlerStateIdle;
            break;
            
        case XIOrganizationHandlerStateInitialRequest:
            return XIOrganizationHandlerStateRunning;
            break;
            
        case XIOrganizationHandlerStateExtendedRequest:
            return XIOrganizationHandlerStateRunning;
            break;
            
        case XIOrganizationHandlerStateRunning:
            assert(0);
            break;
            
        default:
            return (XIOrganizationHandlerState)self.fsm.state;
            break;
    }
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                  callProvider:(id<XIOrganizationInfoCallProvider>)callProvider
                         proxy:(id<XIOrganizationHandler>)proxy
                        access:(XIAccess *)access
                 notifications:(XICOSessionNotifications *)notifications
                        config:(XIServicesConfig *)serviceConfig {
    assert(callProvider);
    assert(access);
    assert(notifications);
    if ((self = [super init])) {
        
        self.fsm = [[XICOFiniteStateMachine alloc] initWithInitialState:XIOrganizationHandlerStateIdle];
        
        // Idle
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateIdle
                                   event: XIOrganizationHandlerGetEventRequest
                                  object: self
                                selector: @selector(onInitialGetRequest:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateIdle
                                   event: XIOrganizationHandlerGetListEventRequest
                                  object: self
                                selector: @selector(onInitialGetListRequest:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateIdle
                                   event: XIOrganizationHandlerEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateIdle
                                   event: XIOrganizationHandlerEventSuspend
                                  object: self
                                selector: @selector(onIdleSuspend:)];
        //Initial Request
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateInitialRequest
                                   event: XIOrganizationHandlerEventCancel
                                  object: self
                                selector: @selector(onRunningCancel:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateInitialRequest
                                   event: XIOrganizationHandlerEventDeviceInfosReceived
                                  object: self
                                selector: @selector(onInitialRequestReceived:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateInitialRequest
                                   event: XIOrganizationHandlerEventError
                                  object: self
                                selector: @selector(onRunningError:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateInitialRequest
                                   event: XIOrganizationHandlerEventSuspend
                                  object: self
                                selector: @selector(onRunningSuspend:)];
        
        //XIDeviceHandlerStateExtendedRequest
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateExtendedRequest
                                   event: XIOrganizationHandlerEventCancel
                                  object: self
                                selector: @selector(onRunningCancel:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateExtendedRequest
                                   event: XIOrganizationHandlerEventDeviceInfosReceived
                                  object: self
                                selector: @selector(onAggregatedRequestReceived:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateExtendedRequest
                                   event: XIOrganizationHandlerEventError
                                  object: self
                                selector: @selector(onRunningError:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateExtendedRequest
                                   event: XIOrganizationHandlerEventSuspend
                                  object: self
                                selector: @selector(onRunningSuspend:)];
        
        //XIDeviceHandlerStateSuspendedWhileRunning
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateSuspendedWhileRunning
                                   event: XIOrganizationHandlerEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateSuspendedWhileRunning
                                   event: XIOrganizationHandlerEventResume
                                  object: self
                                selector: @selector(onInitialGetRequest:)];
        
        //XIDeviceHandlerStateSuspendedWhileIdle
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateSuspendedWhileIdle
                                   event: XIOrganizationHandlerGetEventRequest
                                  object: self
                                selector: @selector(onSuspendedRequest:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateSuspendedWhileIdle
                                   event: XIOrganizationHandlerEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIOrganizationHandlerStateSuspendedWhileIdle
                                   event: XIOrganizationHandlerEventResume
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
        self.aggregatedOrganizationList = [NSMutableArray array];
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
    [_log debug: @"Initial Request object"];
    [self.aggregatedOrganizationList removeAllObjects];
    [self.runningDeviceCalls removeAllObjects];
    
    id<XIOrganizationInfoCall> call = [self.callProvider organizationInfoCall];
    call.delegate = self;
    NSString* organizationId = (NSString *)obj;
    [call getRequestWithOrganizationId:organizationId];
    [self.runningDeviceCalls addObject:call];
    
    return XIOrganizationHandlerStateInitialRequest;
}

- (NSInteger)onInitialGetListRequest:(NSObject *)obj {
    [_log debug: @"Initial Request Listing"];
    [self.aggregatedOrganizationList removeAllObjects];
    [self.runningDeviceCalls removeAllObjects];
    
    id<XIOrganizationInfoCall> call = [self.callProvider organizationInfoCall];
    call.delegate = self;
    [call getListRequestWithAccountId:self.access.accountId];
    [self.runningDeviceCalls addObject:call];
    
    return XIOrganizationHandlerStateInitialRequest;
}


- (NSInteger)onIdleSuspend:(NSObject *)obj {
    [_log debug: @"Initial State canceled"];
    return XIOrganizationHandlerStateSuspendedWhileIdle;
}

- (NSInteger)onIdleCancel:(NSObject *)obj {
    [_log debug: @"Initial State canceled"];
    return XIOrganizationHandlerStateEnded;
}

- (NSInteger)onRunningCancel:(NSObject *)obj {
    [_log debug: @"Running canceled"];
    
    [self cancelAllRunningCallsAndClearLists];
    
    return XIOrganizationHandlerStateCanceled;
}

- (NSInteger)onInitialRequestReceived:(NSDictionary *)parameters {
    XIOrganizationInfo *organizationInfo = parameters[@"organizationInfo"];
    NSArray *organizationInfoList = parameters[@"organizationInfoList"];
    
    [self.runningDeviceCalls removeAllObjects];
    
    if (organizationInfo) {
        [self notifyOnOrganizationInfoWasReceived:organizationInfo];
    } else if (organizationInfoList) {
        [self notifyOnOrganizationInfoListWasReceived:organizationInfoList];
    }
    return XIOrganizationHandlerStateEnded;
}

- (NSInteger)onRunningError:(NSDictionary *)parameters {
    NSError *error = parameters[@"error"];
    [self cancelAllRunningCallsAndClearLists];
    [self notifyOnOrganizationHandlerError:error];
    
    return XIOrganizationHandlerStateError;
}

- (NSInteger)onRunningSuspend:(id)object {
    [self cancelAllRunningCallsAndClearLists];
    return XIOrganizationHandlerStateSuspendedWhileRunning;
}

- (NSInteger)onAggregatedRequestReceived:(NSDictionary *)parameters {
    NSArray *organizationInfoList __unused = parameters[@"organizationInfoList"];
    id<XIOrganizationInfoCall> organizationInfoCall __unused = parameters[@"organizationInfoCall"];
    
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
    return XIOrganizationHandlerStateSuspendedWhileRunning;
}

- (NSInteger)onIdleSuspendedResume:(id)object {
    return XIOrganizationHandlerStateIdle;
}

#pragma mark -
#pragma mark Privates
- (void)cancelAllRunningCallsAndClearLists {
    for (id<XIOrganizationInfoCall> call in self.runningDeviceCalls) {
        call.delegate = nil;
        [call cancel];
    }
    
    [self.aggregatedOrganizationList removeAllObjects];
    [self.runningDeviceCalls removeAllObjects];
}

- (void)notifyOnOrganizationInfoWasReceived:(XIOrganizationInfo *)organizationInfo {
    __weak XIOROrganizationHandler* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XIOrganizationHandlerStateEnded) {
            [weakSelf.delegate organizationHandler:weakSelf didReceiveOrganizationInfo:organizationInfo];
        }
    }});
}

- (void)notifyOnOrganizationInfoListWasReceived:(NSArray *)organizationInfoList {
    __weak XIOROrganizationHandler* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XIOrganizationHandlerStateEnded) {
            [weakSelf.delegate organizationHandler:weakSelf didReceiveList:organizationInfoList];
        }
    }});
}

- (void)notifyOnOrganizationHandlerError:(NSError *)error {
    __weak XIOROrganizationHandler* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XIOrganizationHandlerStateError) {
            weakSelf.error = error;
            [weakSelf.delegate organizationHandler:weakSelf.proxy didFailWithError:error];
        }
    }});
}

#pragma mark -
#pragma mark XIDeviceInfoCallDelegate
- (void)organizationInfoCall:(id<XIOrganizationInfoCall>)organizationInfoCall didSucceedWithOrganizationInfo:(XIOrganizationInfo *)organizationInfo {
    NSDictionary *dict = @{
                           @"organizationInfoCall" : organizationInfoCall,
                           @"organizationInfo" : organizationInfo
                           };
    [self.fsm doEvent:XIOrganizationHandlerEventDeviceInfosReceived withObject:dict];
}

- (void)organizationInfoCall:(id<XIOrganizationInfoCall>)organizationInfoCall didSucceedWithOrganizationInfoList:(NSArray *)organizationInfoList {
    NSDictionary *dict = @{
                           @"organizationInfoCall" : organizationInfoCall,
                           @"organizationInfoList" : organizationInfoList
                           };
    [self.fsm doEvent:XIOrganizationHandlerEventDeviceInfosReceived withObject:dict];
}

- (void)organizationInfoCall:(id<XIOrganizationInfoCall>)organizationInfoCall didFailWithError:(NSError *)error {
    NSDictionary *dict = @{
                           @"organizationInfoCall" : organizationInfoCall,
                           @"error" : error,
                           };
    [self.fsm doEvent:XIOrganizationHandlerEventError withObject:dict];
}

#pragma mark -
#pragma mark Public calls

- (void)requestOrganization:(NSString *)organizationId {
    [self.fsm doEvent:XIOrganizationHandlerGetEventRequest withObject:organizationId];
}

- (void)listOrganizations {
    [self.fsm doEvent:XIOrganizationHandlerGetListEventRequest withObject:nil];
}


- (void)cancel {
    [self.fsm doEvent:XIOrganizationHandlerEventCancel];
}

#pragma mark -
#pragma mark Notifications
- (void)onSessionDidSuspend:(NSNotification *)notification {
    [self.fsm doEvent:XIOrganizationHandlerEventSuspend];
}

- (void)onSessionDidResume:(NSNotification *)notification {
    [self.fsm doEvent:XIOrganizationHandlerEventResume];
}

- (void)onSessionDidClose:(NSNotification *)notification {
    [self.fsm doEvent:XIOrganizationHandlerEventCancel];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    [self.notifications.sessionNotificationCenter removeObserver:self];
}

@end

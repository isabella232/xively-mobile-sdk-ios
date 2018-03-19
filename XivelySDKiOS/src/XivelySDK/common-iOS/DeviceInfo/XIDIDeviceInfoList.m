//
//  XIDIDeviceInfoList.m
//  common-iOS
//
//  Created by vfabian on 25/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIDIDeviceInfoList.h"
#import "XIAccess.h"

typedef NS_ENUM(NSUInteger, XIDeviceInfoListHiddenState) {
    XIDeviceInfoListStateSuspendedWhileRunning = (XIDeviceInfoListStateIdle - 1),
    XIDeviceInfoListStateSuspendedWhileIdle = (XIDeviceInfoListStateIdle - 2),
    XIDeviceInfoListStateInitialRequest = (XIDeviceInfoListStateIdle - 3),
    XIDeviceInfoListStateExtendedRequest = (XIDeviceInfoListStateIdle - 4),
};

typedef NS_ENUM(NSInteger, XIDIDeviceInfoListEvent) {
    XIDIDeviceInfoListEventRequest     = 1,
    XIDIDeviceInfoListEventCancel,
    XIDIDeviceInfoListEventDeviceInfosReceived,
    XIDIDeviceInfoListEventError,
    XIDIDeviceInfoListEventSuspend,
    XIDIDeviceInfoListEventResume,
};

@interface XIDIDeviceInfoList ()

@property(strong, nonatomic) XICOFiniteStateMachine* fsm;
@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIDIDeviceInfoListCallProvider> callProvider;
@property(strong, nonatomic) NSMutableArray *runningDeviceListCalls;
@property(strong, nonatomic) XIAccess* access;

@property(nonatomic, strong)NSError *error;
@property(nonatomic, strong)NSString *associationCode;
@property(nonatomic, strong)XICOSessionNotifications *notifications;
@property(nonatomic, strong)XIServicesConfig *servicesConfig;

@property(nonatomic, strong)NSMutableArray *aggregatedDeviceList;

@end

@implementation XIDIDeviceInfoList

@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize proxy = _proxy;

- (XIDeviceInfoListState)state {
    switch (self.fsm.state) {
        case XIDeviceInfoListStateSuspendedWhileRunning:
            return XIDeviceInfoListStateRunning;
            break;
            
        case XIDeviceInfoListStateSuspendedWhileIdle:
            return XIDeviceInfoListStateIdle;
            break;
            
        case XIDeviceInfoListStateInitialRequest:
            return XIDeviceInfoListStateRunning;
            break;
            
        case XIDeviceInfoListStateExtendedRequest:
            return XIDeviceInfoListStateRunning;
            break;
            
        case XIDeviceInfoListStateRunning:
            assert(0);
            break;
            
        default:
            return (XIDeviceInfoListState)self.fsm.state;
            break;
    }
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                  callProvider:(id<XIDIDeviceInfoListCallProvider>)callProvider
                         proxy:(id<XIDeviceInfoList>)proxy
                        access:(XIAccess *)access
                 notifications:(XICOSessionNotifications *)notifications
                        config:(XIServicesConfig *)serviceConfig {
    assert(callProvider);
    assert(access);
    assert(notifications);
    if ((self = [super init])) {
        
        self.fsm = [[XICOFiniteStateMachine alloc] initWithInitialState:XIDeviceInfoListStateIdle];
        
        // Idle
        [self.fsm addTransitionWithState: XIDeviceInfoListStateIdle
                                   event: XIDIDeviceInfoListEventRequest
                                  object: self
                                selector: @selector(onInitialRequest:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateIdle
                                   event: XIDIDeviceInfoListEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateIdle
                                   event: XIDIDeviceInfoListEventSuspend
                                  object: self
                                selector: @selector(onIdleSuspend:)];
        //Initial Request
        [self.fsm addTransitionWithState: XIDeviceInfoListStateInitialRequest
                                   event: XIDIDeviceInfoListEventCancel
                                  object: self
                                selector: @selector(onRunningCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateInitialRequest
                                   event: XIDIDeviceInfoListEventDeviceInfosReceived
                                  object: self
                                selector: @selector(onInitialRequestReceived:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateInitialRequest
                                   event: XIDIDeviceInfoListEventError
                                  object: self
                                selector: @selector(onRunningError:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateInitialRequest
                                   event: XIDIDeviceInfoListEventSuspend
                                  object: self
                                selector: @selector(onRunningSuspend:)];
        
        //XIDeviceInfoListStateExtendedRequest
        [self.fsm addTransitionWithState: XIDeviceInfoListStateExtendedRequest
                                   event: XIDIDeviceInfoListEventCancel
                                  object: self
                                selector: @selector(onRunningCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateExtendedRequest
                                   event: XIDIDeviceInfoListEventDeviceInfosReceived
                                  object: self
                                selector: @selector(onAggregatedRequestReceived:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateExtendedRequest
                                   event: XIDIDeviceInfoListEventError
                                  object: self
                                selector: @selector(onRunningError:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateExtendedRequest
                                   event: XIDIDeviceInfoListEventSuspend
                                  object: self
                                selector: @selector(onRunningSuspend:)];
        
        //XIDeviceInfoListStateSuspendedWhileRunning
        [self.fsm addTransitionWithState: XIDeviceInfoListStateSuspendedWhileRunning
                                   event: XIDIDeviceInfoListEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateSuspendedWhileRunning
                                   event: XIDIDeviceInfoListEventResume
                                  object: self
                                selector: @selector(onInitialRequest:)];
        
        //XIDeviceInfoListStateSuspendedWhileIdle
        [self.fsm addTransitionWithState: XIDeviceInfoListStateSuspendedWhileIdle
                                   event: XIDIDeviceInfoListEventRequest
                                  object: self
                                selector: @selector(onSuspendedRequest:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateSuspendedWhileIdle
                                   event: XIDIDeviceInfoListEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceInfoListStateSuspendedWhileIdle
                                   event: XIDIDeviceInfoListEventResume
                                  object: self
                                selector: @selector(onIdleSuspendedResume:)];
        
        //XIDeviceInfoListStateEnded
        [self.fsm addTransitionWithState: XIDeviceInfoListStateEnded
                                   event: XIDIDeviceInfoListEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        //XIDeviceInfoListStateError
        [self.fsm addTransitionWithState: XIDeviceInfoListStateError
                                   event: XIDIDeviceInfoListEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];

        self.log = logger;
        self.callProvider = callProvider;
        self.proxy = proxy;
        self.access = access;
        self.notifications = notifications;
        self.aggregatedDeviceList = [NSMutableArray array];
        self.runningDeviceListCalls = [NSMutableArray array];
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
- (NSInteger)onInitialRequest:(NSObject *)obj {
    [_log debug: @"Initial Request Listing"];
    [self.aggregatedDeviceList removeAllObjects];
    [self.runningDeviceListCalls removeAllObjects];
    
    id<XIDIDeviceInfoListCall> call = [self.callProvider deviceInfoListCall];
    call.delegate = self;
    [call requestWithAccountId:self.access.accountId
                                   organizationId:nil
                                         pageSize:self.servicesConfig.blueprintListingMaxPageSize
                                             page:1];
    [self.runningDeviceListCalls addObject:call];
    
    return XIDeviceInfoListStateInitialRequest;
}

- (NSInteger)onIdleSuspend:(NSObject *)obj {
    [_log debug: @"Initial State canceled"];
    return XIDeviceInfoListStateSuspendedWhileIdle;
}

- (NSInteger)onIdleCancel:(NSObject *)obj {
    [_log debug: @"Initial State canceled"];
    return XIDeviceInfoListStateCanceled;
}

- (NSInteger)onRunningCancel:(NSObject *)obj {
    [_log debug: @"Running canceled"];
    
    [self cancelAllRunningCallsAndClearLists];
    
    return XIDeviceInfoListStateCanceled;
}

- (NSInteger)onInitialRequestReceived:(NSDictionary *)parameters {
    XIDIDeviceInfoListMeta *meta = parameters[@"meta"];
    NSArray *deviceInfoList = parameters[@"deviceInfoList"];
    
    [self.runningDeviceListCalls removeAllObjects];
    
    //if the current call returned all devices
    if (meta.pageSize >= meta.count) {
        [self notifyOnDeviceInfoListWasReceived:deviceInfoList];
        return XIDeviceInfoListStateEnded;
        
    } else {
        [self.aggregatedDeviceList addObjectsFromArray:deviceInfoList];
        
        NSInteger const requestPageCount = meta.count / meta.pageSize + ( ( meta.count % meta.pageSize ) ? 1 : 0);
        NSInteger const maxCallPerAggregate = self.servicesConfig.blueprintAggregateMaxCallCount;
        NSInteger pageStartIndex = 2;
        while (pageStartIndex <= requestPageCount) {
            
            id<XIDIDeviceInfoListCall> call = [self.callProvider deviceInfoListCall];
            call.delegate = self;
            [call requestWithAccountId:self.access.accountId
                        organizationId:self.access.blueprintOrganizationId
                              pageSize:meta.pageSize
                             pagesFrom:pageStartIndex
                               pagesTo:MIN((pageStartIndex + maxCallPerAggregate - 1), (requestPageCount))];
            [self.runningDeviceListCalls addObject:call];
            
            pageStartIndex += maxCallPerAggregate;
        }
        return XIDeviceInfoListStateExtendedRequest;
    }
}

- (NSInteger)onRunningError:(NSDictionary *)parameters {
    NSError *error = parameters[@"error"];
    [self cancelAllRunningCallsAndClearLists];
    [self notifyOnDeviceInfoListError:error];
    
    return XIDeviceInfoListStateError;
}

- (NSInteger)onRunningSuspend:(id)object {
    [self cancelAllRunningCallsAndClearLists];
    return XIDeviceInfoListStateSuspendedWhileRunning;
}

- (NSInteger)onAggregatedRequestReceived:(NSDictionary *)parameters {
    NSArray *deviceInfoList = parameters[@"deviceInfoList"];
    id<XIDIDeviceInfoListCall> deviceInfoListCall = parameters[@"deviceInfoListCall"];
    
    //TODO what if the list changes while listing
    
    if ([self.runningDeviceListCalls containsObject:deviceInfoListCall]) {
        [self.runningDeviceListCalls removeObject:deviceInfoListCall];
        [self.aggregatedDeviceList addObjectsFromArray:deviceInfoList];
        
        if (self.runningDeviceListCalls.count == 0) {
            [self notifyOnDeviceInfoListWasReceived:self.aggregatedDeviceList];
            return XIDeviceInfoListStateEnded;
        }
        
    }
    return self.fsm.state;
}

- (NSInteger)onSuspendedRequest:(id)object {
    return XIDeviceInfoListStateSuspendedWhileRunning;
}

- (NSInteger)onIdleSuspendedResume:(id)object {
    return XIDeviceInfoListStateIdle;
}

#pragma mark -
#pragma mark Privates
- (void)cancelAllRunningCallsAndClearLists {
    for (id<XIDIDeviceInfoListCall> call in self.runningDeviceListCalls) {
        call.delegate = nil;
        [call cancel];
    }
    
    [self.aggregatedDeviceList removeAllObjects];
    [self.runningDeviceListCalls removeAllObjects];
}

- (void)notifyOnDeviceInfoListWasReceived:(NSArray *)deviceInfoList {
    __weak XIDIDeviceInfoList* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XIDeviceInfoListStateEnded) {
            [weakSelf.delegate deviceInfoList:weakSelf.proxy didReceiveList:deviceInfoList];
        }
    }});
}

- (void)notifyOnDeviceInfoListError:(NSError *)error {
    __weak XIDIDeviceInfoList* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XIDeviceInfoListStateError) {
            weakSelf.error = error;
            [weakSelf.delegate deviceInfoList:weakSelf.proxy didFailWithError:error];
        }
    }});
}

#pragma mark -
#pragma mark XIDIDeviceInfoListCallDelegate
- (void)deviceInfoListCall:(id<XIDIDeviceInfoListCall>)deviceInfoListCall didSucceedWithDeviceInfoList:(NSArray *)deviceInfoList meta:(XIDIDeviceInfoListMeta *)meta {
    NSDictionary *dict = @{
                           @"deviceInfoListCall" : deviceInfoListCall,
                           @"deviceInfoList" : deviceInfoList,
                           @"meta" : meta
                           };
    [self.fsm doEvent:XIDIDeviceInfoListEventDeviceInfosReceived withObject:dict];
}

- (void)deviceInfoListCall:(id<XIDIDeviceInfoListCall>)deviceInfoListCall didFailWithError:(NSError *)error {
    NSDictionary *dict = @{
                           @"deviceInfoListCall" : deviceInfoListCall,
                           @"error" : error,
                           };
    [self.fsm doEvent:XIDIDeviceInfoListEventError withObject:dict];
}

#pragma mark -
#pragma mark Public calls
- (void)requestList {
    [self.fsm doEvent:XIDIDeviceInfoListEventRequest];
}

- (void)cancel {
    [self.fsm doEvent:XIDIDeviceInfoListEventCancel];
}

#pragma mark -
#pragma mark Notifications
- (void)onSessionDidSuspend:(NSNotification *)notification {
    [self.fsm doEvent:XIDIDeviceInfoListEventSuspend];
}

- (void)onSessionDidResume:(NSNotification *)notification {
    [self.fsm doEvent:XIDIDeviceInfoListEventResume];
}

- (void)onSessionDidClose:(NSNotification *)notification {
    [self.fsm doEvent:XIDIDeviceInfoListEventCancel];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    [self.notifications.sessionNotificationCenter removeObserver:self];
}

@end

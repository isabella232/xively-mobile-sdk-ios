//
//  XITSTimeSeries.m
//  common-iOS
//
//  Created by vfabian on 15/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XITSTimeSeries.h"

typedef NS_ENUM(NSUInteger, XIDeviceHandlerHiddenState) {
    XITimeSeriesStateSuspendedWhileRunning = (XITimeSeriesStateIdle - 1),
    XITimeSeriesStateSuspendedWhileIdle = (XITimeSeriesStateIdle - 2),
};

typedef NS_ENUM(NSInteger, XIDIDeviceInfoListEvent) {
    XITimeSeriesEventRequest     = 1,
    XITimeSeriesEventCancel,
    XITimeSeriesEventDataReceived,
    XITimeSeriesEventError,
    XITimeSeriesEventSuspend,
    XITimeSeriesEventResume,
};

@interface XITSTimeSeries ()

@property(strong, nonatomic) XICOFiniteStateMachine* fsm;
@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XITSTimeSeriesCallProvider> callProvider;
@property(strong, nonatomic) id<XITSTimeSeriesCall> call;
@property(strong, nonatomic) XIAccess* access;

@property(nonatomic, strong)NSError *error;
@property(nonatomic, strong)XICOSessionNotifications *notifications;
@property(nonatomic, strong)XIServicesConfig *servicesConfig;

@property(nonatomic, strong)NSMutableArray *timeSeriesItems;

@property(nonatomic, strong)NSString *channel;
@property(nonatomic, strong)NSDate *startDate;
@property(nonatomic, strong)NSDate *endDate;
@property(nonatomic, strong)NSString *pagingToken;

@end

@implementation XITSTimeSeries

@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize proxy = _proxy;

- (XITimeSeriesState)state {
    switch (self.fsm.state) {
        case XITimeSeriesStateSuspendedWhileRunning:
            return XITimeSeriesStateRunning;
            break;
            
        case XITimeSeriesStateSuspendedWhileIdle:
            return XITimeSeriesStateIdle;
            break;
            
        default:
            return (XITimeSeriesState)self.fsm.state;
            break;
    }
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                  callProvider:(id<XITSTimeSeriesCallProvider>)callProvider
                         proxy:(id<XITimeSeries>)proxy
                        access:(XIAccess *)access
                 notifications:(XICOSessionNotifications *)notifications
                        config:(XIServicesConfig *)serviceConfig {
    assert(callProvider);
    assert(access);
    assert(notifications);
    if ((self = [super init])) {
        
        self.fsm = [[XICOFiniteStateMachine alloc] initWithInitialState:XITimeSeriesStateIdle];
        
        // Idle
        [self.fsm addTransitionWithState: XITimeSeriesStateIdle
                                   event: XITimeSeriesEventRequest
                                  object: self
                                selector: @selector(onIdleRequest:)];
        
        [self.fsm addTransitionWithState: XITimeSeriesStateIdle
                                   event: XITimeSeriesEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XITimeSeriesStateIdle
                                   event: XITimeSeriesEventSuspend
                                  object: self
                                selector: @selector(onIdleSuspend:)];
        
        //Running
        [self.fsm addTransitionWithState: XITimeSeriesStateRunning
                                   event: XITimeSeriesEventCancel
                                  object: self
                                selector: @selector(onRunningCancel:)];
        
        [self.fsm addTransitionWithState: XITimeSeriesStateRunning
                                   event: XITimeSeriesEventDataReceived
                                  object: self
                                selector: @selector(onRunningDataReceived:)];
        
        [self.fsm addTransitionWithState: XITimeSeriesStateRunning
                                   event: XITimeSeriesEventError
                                  object: self
                                selector: @selector(onRunningError:)];
        
        [self.fsm addTransitionWithState: XITimeSeriesStateRunning
                                   event: XITimeSeriesEventSuspend
                                  object: self
                                selector: @selector(onRunningSuspend:)];
        
        
        //SuspendedWhileRunning
        [self.fsm addTransitionWithState: XITimeSeriesStateSuspendedWhileRunning
                                   event: XITimeSeriesEventCancel
                                  object: self
                                selector: @selector(onSuspendedCancel:)];
        
        [self.fsm addTransitionWithState: XITimeSeriesStateSuspendedWhileRunning
                                   event: XITimeSeriesEventResume
                                  object: self
                                selector: @selector(onSuspendedResume:)];
        
        //SuspendedWhileIdle
        [self.fsm addTransitionWithState: XITimeSeriesStateSuspendedWhileIdle
                                   event: XITimeSeriesEventRequest
                                  object: self
                                selector: @selector(onSuspendedIdleRequest:)];
        
        [self.fsm addTransitionWithState: XITimeSeriesStateSuspendedWhileIdle
                                   event: XITimeSeriesEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XITimeSeriesStateSuspendedWhileIdle
                                   event: XITimeSeriesEventResume
                                  object: self
                                selector: @selector(onSuspendedIdleResume:)];
        
        //Ended
        [self.fsm addTransitionWithState: XITimeSeriesStateEnded
                                   event: XITimeSeriesEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        //Error
        [self.fsm addTransitionWithState: XITimeSeriesStateError
                                   event: XITimeSeriesEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        self.log = logger;
        self.callProvider = callProvider;
        self.proxy = proxy;
        self.access = access;
        self.notifications = notifications;
        self.timeSeriesItems = [NSMutableArray array];
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
#pragma mark XITSTimeSeriesCallDelegate
- (void)timeSeriesCall:(id<XITSTimeSeriesCall>)timeSeriesCall didSucceedWithTimeSeriesItems:(NSArray *)timeSeriesItems meta:(XITSTimeSeriesMeta *)meta {
    
    NSDictionary *dict = nil;
    
    if (meta) {
        dict = @{
               @"timeSeriesCall" : timeSeriesCall,
               @"timeSeriesItems" : timeSeriesItems ? timeSeriesItems : @[],
               @"meta" : meta
               };
    } else {
        dict = @{
                 @"timeSeriesCall" : timeSeriesCall,
                 @"timeSeriesItems" : timeSeriesItems ? timeSeriesItems : @[]
                 };
    }
    [self.fsm doEvent:XITimeSeriesEventDataReceived withObject:dict];
}

- (void)timeSeriesCall:(id<XITSTimeSeriesCall>)timeSeriesCall didFailWithError:(NSError *)error {
    NSDictionary *dict = @{
                           @"timeSeriesCall" : timeSeriesCall,
                           @"error" : error,
                           };
    [self.fsm doEvent:XITimeSeriesEventError withObject:dict];
}

#pragma mark -
#pragma mark Public calls
- (void)requestTimeSeriesItemsForChannel:(NSString *)channel startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    assert(channel);
    assert(startDate);
    assert(endDate);
    assert( [startDate laterDate:endDate] == endDate );
    NSDictionary *dict = @{
                           @"channel" : channel,
                           @"startDate" : startDate,
                           @"endDate" : endDate
                           };
    [self.fsm doEvent:XITimeSeriesEventRequest withObject:dict];
}

- (void)cancel {
    [self.fsm doEvent:XITimeSeriesEventCancel];
}

#pragma mark -
#pragma mark State machine
- (NSInteger)onIdleRequest:(NSDictionary *)params {
    [_log debug: @"Initial Request Timeseries"];
    
    self.channel = params[@"channel"];
    self.startDate = params[@"startDate"];
    self.endDate = params[@"endDate"];
    self.pagingToken = nil;
    
    [self.timeSeriesItems removeAllObjects];
    
    [self.call cancel];
    [self initiateCall];
    
    return XITimeSeriesStateRunning;
}

- (NSInteger)onIdleCancel:(id)obj {
    return XITimeSeriesStateCanceled;
}

- (NSInteger)onIdleSuspend:(id)obj {
    return XITimeSeriesStateSuspendedWhileIdle;
}

- (NSInteger)onRunningCancel:(id)obj {
    [self.call cancel];
    self.call = nil;
    return XITimeSeriesStateCanceled;
}

- (NSInteger)onRunningDataReceived:(NSDictionary *)dict {
    NSArray *timeSeriesItems = dict[@"timeSeriesItems"];
    XITSTimeSeriesMeta *meta = dict[@"meta"];
    
    [self.timeSeriesItems addObjectsFromArray:timeSeriesItems];
    
    //if this was the last page, that is determined by having less items in the current page than the page size
    if (meta.count < self.servicesConfig.timeseriesPageSize || !meta.pagingToken) {
        NSArray *timeseriesCopy = [self.timeSeriesItems copy];
        [self.timeSeriesItems removeAllObjects];
        [self notifyOnTimeSeriesItemsReceived:timeseriesCopy];
        return XITimeSeriesStateEnded;
        
    } else {
        self.pagingToken = meta.pagingToken;
        [self initiateCall];
        
        return XITimeSeriesStateRunning;
    }
}

- (NSInteger)onRunningError:(NSDictionary *)dict {
    NSError *error = dict[@"error"];
    [self notifyOnTimeSeriesError:error];
    return XITimeSeriesStateError;
}

- (NSInteger)onRunningSuspend:(id)obj {
    [self.call cancel];
    self.call = nil;
    return XITimeSeriesStateSuspendedWhileRunning;
}

- (NSInteger)onSuspendedCancel:(id)obj {
    return XITimeSeriesStateCanceled;
}

- (NSInteger)onSuspendedResume:(id)obj {
    [self initiateCall];
    return XITimeSeriesStateRunning;
}

- (NSInteger)onSuspendedIdleRequest:(NSDictionary *)params {
    [_log debug: @"Suspended Idle to Initiate Request"];
    
    self.channel = params[@"channel"];
    self.startDate = params[@"startDate"];
    self.endDate = params[@"endDate"];
    self.pagingToken = nil;
    
    return XITimeSeriesStateSuspendedWhileRunning;
}

- (NSInteger)onSuspendedIdleResume:(id)obj {
    return XITimeSeriesStateIdle;
}

#pragma mark -
#pragma mark Privates
- (void)initiateCall {
    self.call = [self.callProvider timeSeriesCall];
    self.call.delegate = self;
    [self.call requestWithTopic:self.channel
                      startDate:self.startDate
                        endDate:self.endDate
                       pageSize:self.servicesConfig.timeseriesPageSize
                    pagingToken:self.pagingToken];
}

- (void)notifyOnTimeSeriesItemsReceived:(NSArray *)timeSeriesItems {
    __weak XITSTimeSeries* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XITimeSeriesStateEnded) {
            [weakSelf.delegate timeSeries:weakSelf.proxy didReceiveItems:timeSeriesItems];
        }
    }});
}

- (void)notifyOnTimeSeriesError:(NSError *)error {
    __weak XITSTimeSeries* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.state == XITimeSeriesStateError) {
            weakSelf.error = error;
            [weakSelf.delegate timeSeries:weakSelf.proxy didFailWithError:error];
        }
    }});
}

#pragma mark -
#pragma mark Notifications
- (void)onSessionDidSuspend:(NSNotification *)notification {
    [self.fsm doEvent:XITimeSeriesEventSuspend];
}

- (void)onSessionDidResume:(NSNotification *)notification {
    [self.fsm doEvent:XITimeSeriesEventResume];
}

- (void)onSessionDidClose:(NSNotification *)notification {
    [self.fsm doEvent:XITimeSeriesEventCancel];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    [self.notifications.sessionNotificationCenter removeObserver:self];
}

@end

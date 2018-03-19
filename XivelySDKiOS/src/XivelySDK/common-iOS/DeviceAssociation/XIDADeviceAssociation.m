//
//  XIDADeviceAssociation.m
//  common-iOS
//
//  Created by vfabian on 16/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIDADeviceAssociation.h"
#import <Internals/Access/XIAccess.h>
#import <XivelySDK/XICommonError.h>
#import <XivelySDK/DeviceAssociation/XIDeviceAssociationError.h>

typedef NS_ENUM(NSUInteger, XIDeviceAssociationHiddenState) {
    XIDeviceAssociationStateSuspendedWhileAssociating = (XIDeviceAssociationStateIdle - 1), /**< The object is suspended while associating. @since Version 1.0 */
    XIDeviceAssociationStateSuspendedWhileIdle = (XIDeviceAssociationStateIdle - 2), /**< The object is suspended while being idle. @since Version 1.0 */
};

typedef NS_ENUM(NSInteger, XIDADeviceAssociationEvent) {
    XIDADeviceAssociationEventAssociate     = 1,
    XIDADeviceAssociationEventCancel,
    XIDADeviceAssociationEventSuccess,
    XIDADeviceAssociationEventError,
    XIDADeviceAssociationEventSuspend,
    XIDADeviceAssociationEventResume,
    
};

@interface XIDADeviceAssociation () <XIDADeviceAssociationCallDelegate>
@property(strong, nonatomic) XICOFiniteStateMachine* fsm;
@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIDADeviceAssociationCallProvider> callProvider;
@property(strong, nonatomic) id<XIDADeviceAssociationCall> deviceAssociationCall;
@property(strong, nonatomic) XIAccess* access;

@property(nonatomic, assign)XIDeviceAssociationState state;
@property(nonatomic, strong)NSError *error;

@property(nonatomic, strong)NSString *associationCode;

@property(nonatomic, strong)XICOSessionNotifications *notifications;
@end

@implementation XIDADeviceAssociation
@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize proxy = _proxy;


-(XIDeviceAssociationState)state {
    switch (_fsm.state) {
        case XIDeviceAssociationStateSuspendedWhileAssociating:
            return XIDeviceAssociationStateAssociating;
            
        case XIDeviceAssociationStateSuspendedWhileIdle:
            return XIDeviceAssociationStateIdle;
            
        default:
            return (XIDeviceAssociationState)[_fsm state];
    }
    
}

- (instancetype)initWithLogger:(id<XICOLogging>)logger
                  callProvider:(id<XIDADeviceAssociationCallProvider>)callProvider
                         proxy:(id<XIDeviceAssociation>)proxy
                        access:(XIAccess*)access
                 notifications:(XICOSessionNotifications *)notifications
                        config:(XIServicesConfig *)serviceConfig {
    assert(callProvider);
    assert(access);
    assert(notifications);
    if ((self = [super init])) {
        
        self.fsm = [[XICOFiniteStateMachine alloc] initWithInitialState:XIDeviceAssociationStateIdle];
        
        // Idle
        [self.fsm addTransitionWithState: XIDeviceAssociationStateIdle
                                   event: XIDADeviceAssociationEventAssociate
                                  object: self
                                selector: @selector(onAssociate:)];
        
        [self.fsm addTransitionWithState: XIDeviceAssociationStateIdle
                                   event: XIDADeviceAssociationEventCancel
                                  object: self
                                selector: @selector(onIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceAssociationStateIdle
                                   event: XIDADeviceAssociationEventSuspend
                                  object: self
                                selector: @selector(onIdleSuspend:)];
        //Associating
        [self.fsm addTransitionWithState: XIDeviceAssociationStateAssociating
                                   event: XIDADeviceAssociationEventCancel
                                  object: self
                                selector: @selector(onAssociatingCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceAssociationStateAssociating
                                   event: XIDADeviceAssociationEventSuccess
                                  object: self
                                selector: @selector(onAssociatingSuccess:)];
        
        [self.fsm addTransitionWithState: XIDeviceAssociationStateAssociating
                                   event: XIDADeviceAssociationEventError
                                  object: self
                                selector: @selector(onAssociatingError:)];
        
        [self.fsm addTransitionWithState: XIDeviceAssociationStateAssociating
                                   event: XIDADeviceAssociationEventSuspend
                                  object: self
                                selector: @selector(onAssociatingSuspend:)];
        //Ended
        [self.fsm addTransitionWithState: XIDeviceAssociationStateEnded
                                   event: XIDADeviceAssociationEventCancel
                                  object: self
                                selector: @selector(onEndedCancel:)];
        //Error
        [self.fsm addTransitionWithState: XIDeviceAssociationStateError
                                   event: XIDADeviceAssociationEventCancel
                                  object: self
                                selector: @selector(onEndedCancel:)];
        //Suspended While Idle
        [self.fsm addTransitionWithState: XIDeviceAssociationStateSuspendedWhileIdle
                                   event: XIDADeviceAssociationEventAssociate
                                  object: self
                                selector: @selector(onSuspendedWhileIdleAssociate:)];
        
        [self.fsm addTransitionWithState: XIDeviceAssociationStateSuspendedWhileIdle
                                   event: XIDADeviceAssociationEventCancel
                                  object: self
                                selector: @selector(onSuspendedWhileIdleCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceAssociationStateSuspendedWhileIdle
                                   event: XIDADeviceAssociationEventResume
                                  object: self
                                selector: @selector(onSuspendedWhileIdleResume:)];
        //Suspended While Associating
        [self.fsm addTransitionWithState: XIDeviceAssociationStateSuspendedWhileAssociating
                                   event: XIDADeviceAssociationEventCancel
                                  object: self
                                selector: @selector(onSuspendedWhileAssociatingCancel:)];
        
        [self.fsm addTransitionWithState: XIDeviceAssociationStateSuspendedWhileAssociating
                                   event: XIDADeviceAssociationEventResume
                                  object: self
                                selector: @selector(onSuspendedWhileAssociatingResume:)];
        
        self.log = logger;
        self.callProvider = callProvider;
        self.proxy = proxy;
        self.access = access;
        self.notifications = notifications;
        
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
#pragma mark Public Interface

#define ADD_PARAM(parameters, x) if (x) parameters[@#x] = x;

- (void)associateDeviceWithAssociationCode:(NSString *)associationCode {
    assert(associationCode.length);
    NSString *associationCodeCopy = [NSString stringWithString:associationCode];
    [self.fsm doEvent: XIDADeviceAssociationEventAssociate withObject:associationCodeCopy];
}

- (void)cancel {
    [self.fsm doEvent:XIDADeviceAssociationEventCancel];
}

- (void)initiateAssociationCall {
    self.deviceAssociationCall = [self.callProvider deviceAssociationCall];
    self.deviceAssociationCall.delegate = self;
    [self.deviceAssociationCall requestWithEndUserId:self.access.blueprintUserId associationCode:self.associationCode];
}

#pragma mark -
#pragma mark Notifications
- (void)onSessionDidSuspend:(NSNotification *)notification {
    [self.fsm doEvent:XIDADeviceAssociationEventSuspend];
}

- (void)onSessionDidResume:(NSNotification *)notification {
    [self.fsm doEvent:XIDADeviceAssociationEventResume];
}

- (void)onSessionDidClose:(NSNotification *)notification {
    [self.fsm doEvent:XIDADeviceAssociationEventCancel];
}


#pragma mark -
#pragma mark Internals Interface
- (NSInteger)onAssociate:(NSString *)associationCode {
    [_log info: @"Request Association"];
    self.associationCode = associationCode;
    [self initiateAssociationCall];
    return XIDeviceAssociationStateAssociating;
}

- (NSInteger)onIdleCancel:(id)object {
    [_log info: @"Idle Canceled"];
    return XIDeviceAssociationStateCanceled;
}

- (NSInteger)onIdleSuspend:(id)object {
    [_log info: @"Idle Suspended"];
    return XIDeviceAssociationStateSuspendedWhileIdle;
}

- (NSInteger)onAssociatingCancel:(id)object {
    [_log info: @"Associating Canceled"];
    [self.deviceAssociationCall cancel];
    return XIDeviceAssociationStateCanceled;
}

- (NSInteger)onAssociatingSuccess:(NSString *)associatedDeviceId {
    [_log info: @"Associating Succeeded"];
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.state == XIDeviceAssociationStateEnded) {
            @autoreleasepool {
                [self.delegate deviceAssociation:self.proxy didSucceedWithDeviceId:associatedDeviceId];
            }
        }
    });
    return XIDeviceAssociationStateEnded;
}

- (NSInteger)onAssociatingError:(NSError *)error {
    [_log info: @"Associating Failed"];
    self.error = error;
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.state == XIDeviceAssociationStateError) {
            @autoreleasepool {
                [self.delegate deviceAssociation:self.proxy didFailWithError:error];
            }
        }
    });
    return XIDeviceAssociationStateError;
}

- (NSInteger)onAssociatingSuspend:(id)object {
    [_log info: @"Associating Suspended"];
    [self.deviceAssociationCall cancel];
    return XIDeviceAssociationStateSuspendedWhileAssociating;
}

- (NSInteger)onEndedCancel:(id)object {
    [_log info: @"Ended Succeeded"];
    return XIDeviceAssociationStateCanceled;
}

- (NSInteger)onSuspendedWhileIdleAssociate:(NSString *)associationCode {
    [_log info: @"Suspended While Idle Associate"];
    self.associationCode = associationCode;
    return XIDeviceAssociationStateSuspendedWhileAssociating;
}

- (NSInteger)onSuspendedWhileIdleCancel:(id)object {
    [_log info: @"Suspended While Idle Cancel"];
    return XIDeviceAssociationStateCanceled;
}

- (NSInteger)onSuspendedWhileIdleResume:(id)object {
    [_log info: @"Suspended While Idle Resume"];
    return XIDeviceAssociationStateIdle;
}

- (NSInteger)onSuspendedWhileAssociatingCancel:(id)object {
    [_log info: @"Suspended While Associating Cancel"];
    return XIDeviceAssociationStateCanceled;
}

- (NSInteger)onSuspendedWhileAssociatingResume:(id)object {
    [_log info: @"Suspended While Associating Resume"];
    [self initiateAssociationCall];
    return XIDeviceAssociationStateAssociating;
}

#pragma mark -
#pragma mark XIDADeviceAssociationCallDelegate
- (void)deviceAssociationCall:(id<XIDADeviceAssociationCall>)deviceAssociationCall didSucceedWithDeviceId:(NSString *)deviceId {
    [self.fsm doEvent:XIDADeviceAssociationEventSuccess withObject:deviceId];
}

- (void)deviceAssociationCall:(id<XIDADeviceAssociationCall>)deviceAssociationCall didFailWithError:(NSError *)error {
    [self.fsm doEvent:XIDADeviceAssociationEventError withObject:error];
}

- (void)dealloc {
    [self.notifications.sessionNotificationCenter removeObserver:self];
}

@end

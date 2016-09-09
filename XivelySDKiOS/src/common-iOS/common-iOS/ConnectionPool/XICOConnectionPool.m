//
//  XICOConnectionPool.m
//  common-iOS
//
//  Created by gszajko on 22/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XICOConnectionPool.h"
#import "XIAccess.h"
#import "NSMutableArray+nonRetaining.h"
#import "XICOCreateMqttCredentialsCallProvider.h"
#import "XICOCreateMqttCredentialsCall.h"
#import <XivelySDK/XICommonError.h>
#import <XivelySDK/Messaging/XIMessagingError.h>
#import <Internals/Session/XICOSessionNotifications.h>


typedef NS_ENUM(NSInteger, XICOConnectionPoolState) {
    XICOConnectionPoolStateIdle,
    XICOConnectionPoolStateCreatingMqttCredentials,
    XICOConnectionPoolStateCreatingConnection,
    XICOConnectionPoolStateRunning,
    
    XICOConnectionPoolStateIdle_suspended,
    XICOConnectionPoolStateCreatingMqttCredentials_suspended,
    XICOConnectionPoolStateCreatingConnection_suspended,
    XICOConnectionPoolStateRunning_suspended,
    
    XICOConnectionPoolStateResumingRunningConnection,
    
    XICOConnectionPoolStateClosed
};

typedef NS_ENUM(NSInteger, XICOConnectionPoolEvent) {
    XICOConnectionPoolEventRequestConnection,
    XICOConnectionPoolEventCancelRequestConnection,
    XICOConnectionPoolEventCancelConnection,
    XICOConnectionPoolEventMqttCredentialsReceived,
    XICOConnectionPoolEventMqttCredentialsReceiveFailed,
    XICOConnectionPoolEventConnected,
    XICOConnectionPoolEventConnectionFailed,
    XICOConnectionPoolEventSuspend,
    XICOConnectionPoolEventResume,
    XICOConnectionPoolEventCloseBySession
};



#pragma mark -
#pragma mark XICOConnectionPool
@interface XICOConnectionPool () <XICOConnectionListener, XICOCreateMqttCredentialsCallDelegate>

@property(nonatomic, strong) XICOFiniteStateMachine* fsm;

@property(nonatomic, strong) XIAccess* access;
@property(nonatomic, strong) XIServicesConfig* servicesConfig;
@property(nonatomic, strong) XICOConnectionFactory* connectionFactory;
@property(nonatomic, strong) NSMutableArray* pendingRequests;           //delegates waiting for call back on connection creation
@property(nonatomic, strong) NSMutableArray* pendingInvalidRequests;    //delegates waiting for call back error on invalid request creation
@property(nonatomic, strong) XICOConnection* connection;
@property(nonatomic) NSInteger connectionReferenceCount;
@property(nonatomic, strong) XICOConnection* pendingConnection;
@property(nonatomic, strong) id<XICOLogging> log;
@property(nonatomic, strong) id<XICOCreateMqttCredentialsCallProvider> createMqttCredentialsCallProvider;
@property(nonatomic, strong) id<XICOCreateMqttCredentialsCall> createMqttCredentialsCall;
@property(nonatomic, strong) XICOSessionNotifications *notifications;
// connection parameters
@property(nonatomic) BOOL connectWithCleanSession;
@property(nonatomic, strong) XILastWill* connectWithLastWill;

-(void) cancelRequestWithDelegate: (id<XICOConnectionPoolDelegate>) delegate;

- (BOOL)isSuspended;

@end

#pragma mark -
#pragma mark Cancelable
@interface XICOConnectionPoolCancelable : NSObject<XICOConnectionPoolCancelable>
@property(nonatomic, weak) XICOConnectionPool* connectionPool;
@property(nonatomic, weak) id<XICOConnectionPoolDelegate> delegate;
@property(nonatomic, assign) id<XICOConnectionPoolDelegate> delegateAssigned; //in case of canceling from dealloc - the weak delegate is nil already, but the managed in the pool is in a nonretained array which holds pointer values not weak references
-(instancetype) initWithConnectionPool: (XICOConnectionPool*) connectionPool
                              delegate: (id<XICOConnectionPoolDelegate>) delegate;
@end

@implementation XICOConnectionPoolCancelable

-(instancetype) initWithConnectionPool: (XICOConnectionPool*) connectionPool
                              delegate: (id<XICOConnectionPoolDelegate>) delegate {

    if ((self = [super init])) {
        
        self.connectionPool = connectionPool;
        self.delegate = delegate;
        self.delegateAssigned = delegate;
    }
    return self;
}

-(void) cancel {
    [self.connectionPool cancelRequestWithDelegate: self.delegateAssigned];
    //second cancel must not break consistency
    self.connectionPool = nil;
}
@end

#pragma mark -
#pragma mark XICOConnectionPool
@implementation XICOConnectionPool
@synthesize jwt = _jwt;

- (BOOL)isSuspended {
    switch (self.fsm.state) {
        case XICOConnectionPoolStateIdle_suspended:
        case XICOConnectionPoolStateCreatingMqttCredentials_suspended:
        case XICOConnectionPoolStateCreatingConnection_suspended:
        case XICOConnectionPoolStateRunning_suspended:
            return YES;
            
        default:
            return NO;
    }
}

#pragma mark -
#pragma mark Constructor/Destructor
-(instancetype) initWithAccess: (XIAccess*) access
                servicesConfig: (XIServicesConfig*) servicesConfig
             connectionFactory: (XICOConnectionFactory*) connectionFactory
                        logger: (id<XICOLogging>) logger
createMqttCredentialsCallProvider:(id<XICOCreateMqttCredentialsCallProvider>)createMqttCredentialsCallProvider
                 notifications:(XICOSessionNotifications *)notifications{
    
    if ((self = [super init])) {
        
        self.access = access;
        self.servicesConfig = servicesConfig;
        self.connectionFactory = connectionFactory;
        self.pendingRequests = [NSMutableArray XINonRetainingArrayWithCapacity: 0];
        self.pendingInvalidRequests = [NSMutableArray XINonRetainingArrayWithCapacity: 0];
        self.log = logger;
        self.createMqttCredentialsCallProvider = createMqttCredentialsCallProvider;
        self.notifications = notifications;
        
        self.fsm = [[XICOFiniteStateMachine alloc] initWithInitialState: XICOConnectionPoolStateIdle];
        
        //XICOConnectionPoolStateIdle
        [self.fsm addTransitionWithState: XICOConnectionPoolStateIdle
                               event: XICOConnectionPoolEventRequestConnection
                              object: self
                            selector: @selector(onIdleRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateIdle
                                   event: XICOConnectionPoolEventSuspend
                                  object: self
                                selector: @selector(onIdleSuspend:)];
        
            //suspended
        [self.fsm addTransitionWithState: XICOConnectionPoolStateIdle_suspended
                                   event: XICOConnectionPoolEventRequestConnection
                                  object: self
                                selector: @selector(onSuspendedIdleRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateIdle_suspended
                                   event: XICOConnectionPoolEventResume
                                  object: self
                                selector: @selector(onIdleResume:)];
        
        
        //XICOConnectionPoolStateCreatingMqttCredentials
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials
                               event: XICOConnectionPoolEventRequestConnection
                              object: self
                            selector: @selector(onCreatingConnectionRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials
                               event: XICOConnectionPoolEventCancelRequestConnection
                              object: self
                            selector: @selector(onCreatingMqttCredentialsCancelRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials
                               event: XICOConnectionPoolEventMqttCredentialsReceived
                              object: self
                            selector: @selector(onCreatingMqttCredentialsMqttCredentialsReceived:)];

        [self.fsm addTransitionWithState: XICOConnectionPoolStateIdle
                                   event: XICOConnectionPoolEventMqttCredentialsReceived
                                  object: self
                                selector: @selector(onCreatingMqttCredentialsMqttCredentialsReceived:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials
                               event: XICOConnectionPoolEventMqttCredentialsReceiveFailed
                              object: self
                            selector: @selector(onCreatingMqttCredentialsFailed:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials
                                   event: XICOConnectionPoolEventSuspend
                                  object: self
                                selector: @selector(onCreatingMqttCredentialsSuspend:)];
            //suspended
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials_suspended
                                   event: XICOConnectionPoolEventRequestConnection
                                  object: self
                                selector: @selector(onCreatingConnectionRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials_suspended
                                   event: XICOConnectionPoolEventCancelRequestConnection
                                  object: self
                                selector: @selector(onCreatingMqttCredentialsCancelRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials_suspended
                                   event: XICOConnectionPoolEventResume
                                  object: self
                                selector: @selector(onCreatingMqttCredentialsResume:)];
        
        
        
        //XICOConnectionPoolStateCreatingConnection
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection
                               event: XICOConnectionPoolEventRequestConnection
                              object: self
                            selector: @selector(onCreatingConnectionRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection
                               event: XICOConnectionPoolEventCancelRequestConnection
                              object: self
                            selector: @selector(onCreatingConnectionCancelRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection
                               event: XICOConnectionPoolEventConnected
                              object: self
                            selector: @selector(onCreatingConnectionConnected:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection
                               event: XICOConnectionPoolEventConnectionFailed
                              object: self
                            selector: @selector(onCreatingConnectionFailed:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection
                                   event: XICOConnectionPoolEventSuspend
                                  object: self
                                selector: @selector(onCreatingConnectionSuspend:)];
        
            //suspended
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection_suspended
                                   event: XICOConnectionPoolEventRequestConnection
                                  object: self
                                selector: @selector(onCreatingConnectionRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection_suspended
                                   event: XICOConnectionPoolEventCancelRequestConnection
                                  object: self
                                selector: @selector(onCreatingConnectionCancelRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection_suspended
                                   event: XICOConnectionPoolEventResume
                                  object: self
                                selector: @selector(onCreatingConnectionResume:)];
        
        //XICOConnectionPoolStateRunning
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning
                               event: XICOConnectionPoolEventRequestConnection
                              object: self
                            selector: @selector(onRunningRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning
                               event: XICOConnectionPoolEventCancelRequestConnection
                              object: self
                            selector: @selector(onRunningCancelRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning
                               event: XICOConnectionPoolEventCancelConnection
                              object: self
                            selector: @selector(onRunningCancelConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning
                               event: XICOConnectionPoolEventConnectionFailed
                              object: self
                            selector: @selector(onRunningconnectionFailed:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning
                                   event: XICOConnectionPoolEventSuspend
                                  object: self
                                selector: @selector(onRunningConnectionSuspend:)];
            //suspended
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning_suspended
                                   event: XICOConnectionPoolEventRequestConnection
                                  object: self
                                selector: @selector(onRunningRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning_suspended
                                   event: XICOConnectionPoolEventCancelRequestConnection
                                  object: self
                                selector: @selector(onRunningCancelRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning_suspended
                                   event: XICOConnectionPoolEventCancelConnection
                                  object: self
                                selector: @selector(onRunningCancelConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning_suspended
                                   event: XICOConnectionPoolEventResume
                                  object: self
                                selector: @selector(onRunningConnectionResume:)];
        
        //close by session
        [self.fsm addTransitionWithState: XICOConnectionPoolStateIdle
                                   event: XICOConnectionPoolEventCloseBySession
                                  object: self
                                selector: @selector(onCloseBySession:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials
                                   event: XICOConnectionPoolEventCloseBySession
                                  object: self
                                selector: @selector(onCloseBySession:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection
                                   event: XICOConnectionPoolEventCloseBySession
                                  object: self
                                selector: @selector(onCloseBySession:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning
                                   event: XICOConnectionPoolEventCloseBySession
                                  object: self
                                selector: @selector(onCloseBySession:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateIdle_suspended
                                   event: XICOConnectionPoolEventCloseBySession
                                  object: self
                                selector: @selector(onCloseBySession:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingMqttCredentials_suspended
                                   event: XICOConnectionPoolEventCloseBySession
                                  object: self
                                selector: @selector(onCloseBySession:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateCreatingConnection_suspended
                                   event: XICOConnectionPoolEventCloseBySession
                                  object: self
                                selector: @selector(onCloseBySession:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateRunning_suspended
                                   event: XICOConnectionPoolEventCloseBySession
                                  object: self
                                selector: @selector(onCloseBySession:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateResumingRunningConnection
                                   event: XICOConnectionPoolEventCloseBySession
                                  object: self
                                selector: @selector(onCloseBySession:)];
        
        
        
        //XICOConnectionPoolStateResumingRunningConnection
        [self.fsm addTransitionWithState: XICOConnectionPoolStateResumingRunningConnection
                                   event: XICOConnectionPoolEventRequestConnection
                                  object: self
                                selector: @selector(onCreatingConnectionRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateResumingRunningConnection
                                   event: XICOConnectionPoolEventCancelRequestConnection
                                  object: self
                                selector: @selector(onResumingConnectionCancelRequestConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateResumingRunningConnection
                                   event: XICOConnectionPoolEventCancelConnection
                                  object: self
                                selector: @selector(onResumingConnectionCancelConnection:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateResumingRunningConnection
                                   event: XICOConnectionPoolEventConnected
                                  object: self
                                selector: @selector(onResumingConnectionConnected:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateResumingRunningConnection
                                   event: XICOConnectionPoolEventConnectionFailed
                                  object: self
                                selector: @selector(onResumingConnectionFailed:)];
        
        [self.fsm addTransitionWithState: XICOConnectionPoolStateResumingRunningConnection
                                   event: XICOConnectionPoolEventSuspend
                                  object: self
                                selector: @selector(onCreatingConnectionSuspend:)];
        
        
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

- (void)dealloc {
    [self.notifications.sessionNotificationCenter removeObserver:self];
    [self.pendingConnection removeListener:self];
    [self.connection removeListener:self];
}

#pragma mark -
#pragma mark Notifications
- (void)onSessionDidSuspend:(NSNotification *)notification {
    [self.fsm doEvent:XICOConnectionPoolEventSuspend];
}

- (void)onSessionDidResume:(NSNotification *)notification {
    [self.fsm doEvent:XICOConnectionPoolEventResume];
}

- (void)onSessionDidClose:(NSNotification *)notification {
    [self.fsm doEvent:XICOConnectionPoolEventCloseBySession];
}


#pragma mark -
#pragma mark XICOConnectionPooling
-(id<XICOConnectionPoolCancelable>) requestConnectionWithDelegate: (id<XICOConnectionPoolDelegate>) delegate {
    
    return [self requestConnectionWithCleanSession: YES
                                          delegate: delegate];
}

-(id<XICOConnectionPoolCancelable>) requestConnectionWithCleanSession: (BOOL) cleanSession
                                                             delegate: (id<XICOConnectionPoolDelegate>) delegate {
    
    return [self requestConnectionWithCleanSession: cleanSession
                                          lastWill: nil
                                          delegate: delegate];
}

-(id<XICOConnectionPoolCancelable>) requestConnectionWithCleanSession: (BOOL) cleanSession
                                                           lastWill: (XILastWill*) lastWill
                                                           delegate: (id<XICOConnectionPoolDelegate>) delegate {
    return [self requestConnectionWithCleanSession: cleanSession
                                          lastWill: lastWill
                                               jwt: nil
                                          delegate: delegate];
}

-(id<XICOConnectionPoolCancelable>) requestConnectionWithCleanSession: (BOOL) cleanSession
                                                             lastWill: (XILastWill*) lastWill
                                                                  jwt: (NSString*)jwt
                                                             delegate: (id<XICOConnectionPoolDelegate>) delegate {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"delegate"] = delegate;
    params[@"cleanSession"] = @(cleanSession);
    if (lastWill) {
        params[@"lastWill"] = lastWill;
    }
    if (jwt) {
        params[@"jwt"] = jwt;
    }
    
    [self.fsm doEvent:XICOConnectionPoolEventRequestConnection withObject:params];
    
    return params[@"cancelable"];
}

-(void) cancelRequestWithDelegate: (id<XICOConnectionPoolDelegate>) delegate {
    [self.fsm doEvent:XICOConnectionPoolEventCancelRequestConnection withObject:delegate];
}

-(void) releaseConnection: (id<XICOConnecting>) connection {
    [self.fsm doEvent:XICOConnectionPoolEventCancelConnection withObject:connection];
}

#pragma mark -
#pragma mark XICOConnectionListener
-(void) connection: (id<XICOConnecting>) connection didConnectedToBroker: (NSURL*) broker {
    [self.fsm doEvent:XICOConnectionPoolEventConnected withObject:connection];
}

-(void) connection: (id<XICOConnecting>) connection didFailToConnect: (NSError*) error {
    NSDictionary *dict = @{@"connection" : connection, @"error" : error};
    [self.fsm doEvent:XICOConnectionPoolEventConnectionFailed withObject:dict];
}

#pragma mark -
#pragma mark XICOCreateMqttCredentialsCallDelegate
- (void)createMqttCredentialsCall:(id<XICOCreateMqttCredentialsCall>)createMqttCredentialsCall
       didSucceedWithMqttUserName:(NSString *)mqttUserName
                     mqttPassword:(NSString *)mqttPassword {
    NSDictionary *dict = @{@"mqttUserName" : mqttUserName, @"mqttPassword" : mqttPassword};
    [self.fsm doEvent:XICOConnectionPoolEventMqttCredentialsReceived withObject:dict];
    
}

- (void)createMqttCredentialsCall:(id<XICOCreateMqttCredentialsCall>)createMqttCredentialsCall didFailWithError:(NSError *)error {
    [self.fsm doEvent:XICOConnectionPoolEventMqttCredentialsReceiveFailed withObject:error];
}

#pragma mark -
#pragma mark Private methods
- (void)connectionFailed:(NSError*)error {
    for (id<XICOConnectionPoolDelegate> delegate in [self.pendingRequests copy]) {
        [delegate connectionPool: self didFailToCreateConnection: error];
    }
    [self.pendingRequests removeAllObjects];
}

- (XICOConnectionPoolState) onIdleRequestConnection: (NSDictionary*)dict {
    [self.log debug: @"request connection - start to getmqtt credentials"];
    self.connectionReferenceCount = 1;
    [self.pendingRequests removeAllObjects];
    
    self.connectWithCleanSession = [dict[@"cleanSession"] boolValue];
    self.connectWithLastWill = dict[@"lastWill"];
    
    id<XICOConnectionPoolDelegate> delegateParam = (id<XICOConnectionPoolDelegate>)(dict[@"delegate"]);
    [self.pendingRequests addObject:delegateParam];
    
    NSMutableDictionary *mutableParams = (NSMutableDictionary *)dict;
    mutableParams[@"cancelable"] = [[XICOConnectionPoolCancelable alloc] initWithConnectionPool:self
                                                                                       delegate:delegateParam];
    
    NSString* jwt = [dict objectForKey:@"jwt"];
    if (jwt)
    {
        [self.fsm doEvent:XICOConnectionPoolEventMqttCredentialsReceived withObject:@{@"jwt": jwt}];
        return XICOConnectionPoolStateCreatingConnection;
    } else {
        self.createMqttCredentialsCall = [self.createMqttCredentialsCallProvider createMqttCredentialsCall];
        self.createMqttCredentialsCall.delegate = self;
        [self requestMqttCredentials];
        return XICOConnectionPoolStateCreatingMqttCredentials;
    }
}

- (void)requestMqttCredentials {
    if (self.access.blueprintUserType == XIAccessBlueprintUserTypeEndUser) {
        [self.createMqttCredentialsCall requestWithEndUserId:self.access.blueprintUserId accountId:self.access.accountId];
    } else if (self.access.blueprintUserType == XIAccessBlueprintUserTypeAccountUser) {
        [self.createMqttCredentialsCall requestWithAccountUserId:self.access.blueprintUserId accountId:self.access.accountId];
    } else {
        assert(0);
    }
}

- (BOOL)connectionRequestIsValidWithCleanSession:(BOOL)cleanSession lastWill:(XILastWill *)lastWill {
    return self.connectWithCleanSession == cleanSession &&
        ((self.connectWithLastWill == nil && lastWill == nil) ||
        (self.connectWithLastWill && lastWill && [self.connectWithLastWill isEqualToLastWill: lastWill]));
}

- (XICOConnectionPoolState)onCreatingConnectionRequestConnection:(NSDictionary*)dict {
    [self.log debug: @"request connection - already getting connection"];
    
    __weak id<XICOConnectionPoolDelegate> delegateParam = (id<XICOConnectionPoolDelegate>)(dict[@"delegate"]);
    NSMutableDictionary *mutableParams = (NSMutableDictionary *)dict;
    mutableParams[@"cancelable"] = [[XICOConnectionPoolCancelable alloc] initWithConnectionPool:self
                                                                                       delegate:delegateParam];
    
    XILastWill* lastWill = dict[@"lastWill"];
    
    if (![self connectionRequestIsValidWithCleanSession:[dict[@"cleanSession"] boolValue] lastWill:lastWill]) {
        [self.pendingInvalidRequests addObject:delegateParam];
        if (self.pendingInvalidRequests.count == 1) {
            dispatch_async(dispatch_get_main_queue(), ^(){@autoreleasepool {
                
                for (id<XICOConnectionPoolDelegate> dp in [self.pendingInvalidRequests copy]) {
                    [dp connectionPool: self didFailToCreateConnection: [NSError errorWithDomain: @"XIConnectionPool"
                                                                                                   code: XIMessagingErrorInvalidConnectParameters
                                                                                               userInfo: nil]];
                }
                [self.pendingInvalidRequests removeAllObjects];
                
            }});
        }
        
        return self.fsm.state;
    }
    
    self.connectionReferenceCount++;
    
    [self.pendingRequests addObject:delegateParam];
    return self.fsm.state;
}

- (XICOConnectionPoolState)onCreatingMqttCredentialsCancelRequestConnection:(id<XICOConnectionPoolDelegate>)delegate {
    id<XICOConnectionPoolDelegate> delegateParam = delegate;
    [self.log debug: @"cancel request connection - already getting connection"];
    if ([self.pendingInvalidRequests containsObject:delegateParam]) {
        [self.pendingInvalidRequests removeObject:delegateParam];
        return self.fsm.state;
        
    } else if ([self.pendingRequests containsObject:delegateParam]) {
        
        [self.pendingRequests removeObject:delegateParam];
        self.connectionReferenceCount--;
        
        if (self.connectionReferenceCount <= 0) {
            [self.createMqttCredentialsCall cancel];
            self.createMqttCredentialsCall = nil;
            return (self.isSuspended) ? XICOConnectionPoolStateIdle_suspended : XICOConnectionPoolStateIdle;
            
        } else {
            return self.fsm.state;
        }
        
    } else {
        return self.fsm.state;
    }
}

- (XICOConnectionPoolState)onCreatingMqttCredentialsMqttCredentialsReceived:(NSDictionary*)dict {
    [self.log debug: @"mqtt credentials received"];
    
    NSString *mqttPassword = dict[@"mqttPassword"];
    
    self.access.mqttPassword = mqttPassword;
    self.createMqttCredentialsCall = nil;
    
    self.pendingConnection = [self.connectionFactory createConnectionWithLogger: [[XICOLogger sharedLogger] createLoggerWithFacility: @"Connection"]
                                                         connectionPool: self];
    
    [self.pendingConnection addListener: self];
    NSString* jwt = [dict objectForKey:@"jwt"];
    
    if (jwt) {
        [self.pendingConnection connectWithUrl: [NSURL URLWithString: self.servicesConfig.mqttBrokerUrl]
                                      username: @"Auth:JWT"
                                      password: jwt
                                  cleanSession: self.connectWithCleanSession
                                      lastWill: self.connectWithLastWill];
    } else {
        [self.pendingConnection connectWithUrl: [NSURL URLWithString: self.servicesConfig.mqttBrokerUrl]
                                      username: self.access.mqttUsername
                                      password: mqttPassword
                                  cleanSession: self.connectWithCleanSession
                                      lastWill: self.connectWithLastWill];
    }

    return XICOConnectionPoolStateCreatingConnection;
}


- (XICOConnectionPoolState)onCreatingMqttCredentialsFailed:(NSError *)error {
    [self.log debug: @"mqtt credential creation failed"];
    [self connectionFailed:error];
    self.createMqttCredentialsCall = nil;
    return XICOConnectionPoolStateIdle;
}

- (XICOConnectionPoolState)onCreatingConnectionCancelRequestConnection:(id<XICOConnectionPoolDelegate>)delegate {
    id<XICOConnectionPoolDelegate> delegateParam = delegate;
    [self.log debug: @"cancel request connection - already getting connection"];
    if ([self.pendingInvalidRequests containsObject:delegateParam]) {
        [self.pendingInvalidRequests removeObject:delegateParam];
        return self.fsm.state;
        
    } else if ([self.pendingRequests containsObject:delegateParam]) {
        
        [self.pendingRequests removeObject:delegateParam];
        self.connectionReferenceCount--;
        
        if (self.connectionReferenceCount <= 0) {
            [self.pendingConnection removeListener:self];
            [self.pendingConnection disconnect];
            self.pendingConnection = nil;
            return (self.isSuspended) ? XICOConnectionPoolStateIdle_suspended : XICOConnectionPoolStateIdle;
            
        } else {
            return self.fsm.state;
        }
        
    } else {
        return self.fsm.state;
    }
}

- (XICOConnectionPoolState)onCreatingConnectionConnected:(id<XICOConnecting>)connection {
    [self.log info: @"connection connected"];
    if (self.pendingConnection != connection) return self.fsm.state;
    
    self.connection = self.pendingConnection;
    self.pendingConnection = nil;
    
    for (id<XICOConnectionPoolDelegate> delegate in [self.pendingRequests copy]) {
        [delegate connectionPool: self didCreateConnection: self.connection];
    }
    [self.pendingRequests removeAllObjects];
    
    return XICOConnectionPoolStateRunning;
}

- (XICOConnectionPoolState)onCreatingConnectionFailed:(NSDictionary *)dict {
    NSError *error = dict[@"error"];
    id<XICOConnecting> connection = dict[@"connection"];
    if (connection == self.pendingConnection) {
        [self.pendingConnection removeListener:self];
        self.pendingConnection = nil;
        if (!error) error = [NSError errorWithDomain:@"Connection pool" code:XIErrorInternal userInfo:nil];
        [self connectionFailed:error];
        return XICOConnectionPoolStateIdle;
    } else {
        return self.fsm.state;
    }
}

- (XICOConnectionPoolState)onRunningRequestConnection:(NSDictionary *)dict {
    [self.log debug: @"request connection - already running connection"];
    
    __weak id<XICOConnectionPoolDelegate> delegateParam = (id<XICOConnectionPoolDelegate>)(dict[@"delegate"]);
    NSMutableDictionary *mutableParams = (NSMutableDictionary *)dict;
    mutableParams[@"cancelable"] = [[XICOConnectionPoolCancelable alloc] initWithConnectionPool:self
                                                                                       delegate:delegateParam];
    
    XILastWill* lastWill = dict[@"lastWill"];
    if (![self connectionRequestIsValidWithCleanSession:[dict[@"cleanSession"] boolValue] lastWill:lastWill]) {
        [self.pendingInvalidRequests addObject:delegateParam];
        if (self.pendingInvalidRequests.count == 1) {
            dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
                
                for (id<XICOConnectionPoolDelegate> dp in [self.pendingInvalidRequests copy]) {
                    [dp connectionPool: self didFailToCreateConnection: [NSError errorWithDomain: @"XIConnectionPool"
                                                                                                   code: XIMessagingErrorInvalidConnectParameters
                                                                                               userInfo: nil]];
                    [self.pendingInvalidRequests removeAllObjects];
                }
            }});
        }
        
        return self.fsm.state;
    }
    
    self.connectionReferenceCount++;
    
    [self.pendingRequests addObject:delegateParam];
    
    dispatch_async(dispatch_get_main_queue(), ^(){ @autoreleasepool {
        if (self.fsm.state != XICOConnectionPoolStateRunning && self.fsm.state != XICOConnectionPoolStateRunning_suspended) return;
        for (id<XICOConnectionPoolDelegate> delegate in [self.pendingRequests copy]) {
            [delegate connectionPool: self didCreateConnection: self.connection];
        }
        [self.pendingRequests removeAllObjects];
    }});
    
    
    return self.fsm.state;
}

- (XICOConnectionPoolState)onRunningCancelRequestConnection:(id<XICOConnectionPoolDelegate>)delegate {
    id<XICOConnectionPoolDelegate> delegateParam = delegate;
    [self.log debug: @"cancel request connection - connection is on"];
    if ([self.pendingInvalidRequests containsObject:delegateParam]) {
        [self.pendingInvalidRequests removeObject:delegateParam];
        return self.fsm.state;
        
    } else if ([self.pendingRequests containsObject:delegateParam]) {
        
        [self.pendingRequests removeObject:delegateParam];
        self.connectionReferenceCount--;
        
        if (self.connectionReferenceCount <= 0) {
            [self.connection removeListener:self];
            [self.connection disconnect];
            self.connection = nil;
            
            return (self.isSuspended) ? XICOConnectionPoolStateIdle_suspended : XICOConnectionPoolStateIdle;
            
        } else {
            return self.fsm.state;
        }
        
    } else {
        return self.fsm.state;
    }
}

- (XICOConnectionPoolState)onRunningCancelConnection:(id<XICOConnecting>)connection {
    [self.log debug: @"cancel connection - connection is on"];
    
    if (self.connection == connection) {
        self.connectionReferenceCount--;
        
        if (self.connectionReferenceCount <= 0) {
            [self.connection removeListener:self];
            [self.connection disconnect];
            self.connection = nil;
            
            return (self.isSuspended) ? XICOConnectionPoolStateIdle_suspended : XICOConnectionPoolStateIdle;
            
        } else {
            return self.fsm.state;
        }
        
    } else {
        return self.fsm.state;
    }
}

- (XICOConnectionPoolState)onRunningconnectionFailed:(NSDictionary *)dict {
    [self.log debug: @"connection failed - connection is on"];
    
    id<XICOConnecting> connection = dict[@"connection"];
    if (connection == self.connection) {
        [self.connection removeListener:self];
        self.connection = nil;
        return XICOConnectionPoolStateIdle;
    } else {
        return self.fsm.state;
    }
}

#pragma mark -
#pragma mark Suspend
- (XICOConnectionPoolState)onIdleSuspend:(NSDictionary *)dict {
    [self.log debug: @"idle suspended"];
    return XICOConnectionPoolStateIdle_suspended;
}

- (XICOConnectionPoolState)onSuspendedIdleRequestConnection:(NSDictionary *)dict {
    [self.log debug: @"idle suspended request connection"];
    
    self.connectionReferenceCount = 1;
    [self.pendingRequests removeAllObjects];
    
    id<XICOConnectionPoolDelegate> delegateParam = (id<XICOConnectionPoolDelegate>)(dict[@"delegate"]);
    [self.pendingRequests addObject:delegateParam];
    
    NSMutableDictionary *mutableParams = (NSMutableDictionary *)dict;
    mutableParams[@"cancelable"] = [[XICOConnectionPoolCancelable alloc] initWithConnectionPool:self
                                                                                       delegate:delegateParam];
    
    self.connectWithCleanSession = [dict[@"cleanSession"] boolValue];
    self.connectWithLastWill = dict[@"lastWill"];
    
    return XICOConnectionPoolStateCreatingMqttCredentials_suspended;
}

- (XICOConnectionPoolState)onCreatingMqttCredentialsSuspend:(NSDictionary *)dict {
    [self.log debug: @"creating mqtt credentials suspended"];
    [self.createMqttCredentialsCall cancel];
    self.createMqttCredentialsCall = nil;
    return XICOConnectionPoolStateCreatingMqttCredentials_suspended;
}

- (XICOConnectionPoolState)onCreatingConnectionSuspend:(NSDictionary *)dict {
    [self.log debug: @"creating mqtt connection suspended"];
    return XICOConnectionPoolStateCreatingConnection_suspended;
}

- (XICOConnectionPoolState)onRunningConnectionSuspend:(NSDictionary *)dict {
    [self.log debug: @"running connection suspended"];
    return XICOConnectionPoolStateRunning_suspended;
}

- (XICOConnectionPoolState)onResumingConnectionConnected:(id<XICOConnecting>)connection {
    [self.log info: @"resuming connection connected"];
    if (self.connection != connection) return self.fsm.state;
    
    for (id<XICOConnectionPoolDelegate> delegate in [self.pendingRequests copy]) {
        [delegate connectionPool: self didCreateConnection: self.connection];
    }
    [self.pendingRequests removeAllObjects];
    
    return XICOConnectionPoolStateRunning;
}

- (XICOConnectionPoolState)onResumingConnectionFailed:(NSDictionary *)dict {
    NSError *error = dict[@"error"];
    id<XICOConnecting> connection = dict[@"connection"];
    if (connection == self.connection) {
        [self.connection removeListener:self];
        self.connection = nil;
        if (!error) error = [NSError errorWithDomain:@"Connection pool" code:XIErrorInternal userInfo:nil];
        [self connectionFailed:error];
        return XICOConnectionPoolStateIdle;
    } else {
        return self.fsm.state;
    }
}

- (XICOConnectionPoolState)onResumingConnectionCancelRequestConnection:(id<XICOConnectionPoolDelegate>)delegate {
    id<XICOConnectionPoolDelegate> delegateParam = delegate;
    [self.log debug: @"cancel request connection - already getting connection"];
    if ([self.pendingInvalidRequests containsObject:delegateParam]) {
        [self.pendingInvalidRequests removeObject:delegateParam];
        return self.fsm.state;
        
    } else if ([self.pendingRequests containsObject:delegateParam]) {
        
        [self.pendingRequests removeObject:delegateParam];
        self.connectionReferenceCount--;
        
        if (self.connectionReferenceCount <= 0) {
            [self.connection removeListener:self];
            [self.connection disconnect];
            self.connection = nil;
            return (self.isSuspended) ? XICOConnectionPoolStateIdle_suspended : XICOConnectionPoolStateIdle;
            
        } else {
            return self.fsm.state;
        }
        
    } else {
        return self.fsm.state;
    }
}

- (XICOConnectionPoolState)onResumingConnectionCancelConnection:(id<XICOConnecting>)connection {
    [self.log debug: @"cancel connection - connection is on"];
    
    if (self.connection == connection) {
        self.connectionReferenceCount--;
        
        if (self.connectionReferenceCount <= 0) {
            [self.connection removeListener:self];
            [self.connection disconnect];
            self.connection = nil;
            
            return (self.isSuspended) ? XICOConnectionPoolStateIdle_suspended : XICOConnectionPoolStateIdle;
            
        } else {
            return self.fsm.state;
        }
        
    } else {
        return self.fsm.state;
    }
}

#pragma mark -
#pragma mark Resume
- (XICOConnectionPoolState)onIdleResume:(NSDictionary *)dict {
    [self.log debug: @"idle resumed"];
    return XICOConnectionPoolStateIdle;
}

- (XICOConnectionPoolState)onCreatingMqttCredentialsResume:(NSDictionary *)dict {
    [self.log debug: @"creating mqtt credentials resumed"];
    self.createMqttCredentialsCall = [self.createMqttCredentialsCallProvider createMqttCredentialsCall];
    self.createMqttCredentialsCall.delegate = self;
    [self requestMqttCredentials];
    return XICOConnectionPoolStateCreatingMqttCredentials;
}

- (XICOConnectionPoolState)onCreatingConnectionResume:(NSDictionary *)dict {
    [self.log debug: @"creating mqtt connection resumed"];
    return XICOConnectionPoolStateCreatingConnection;
}

- (XICOConnectionPoolState)onRunningConnectionResume:(NSDictionary *)dict {
    [self.log debug: @"running mqtt connection resumed"];
    return XICOConnectionPoolStateResumingRunningConnection;
}

#pragma mark -
#pragma mark Close by Xively Session
- (XICOConnectionPoolState)onCloseBySession:(NSDictionary *)dict {
    [self.log debug: @"creating mqtt connection resumed"];
    [self.createMqttCredentialsCall cancel];
    self.createMqttCredentialsCall = nil;
    [self.pendingConnection disconnect];
    self.pendingConnection = nil;
    [self.connection disconnect];
    self.connection = nil;
    
    return XICOConnectionPoolStateClosed;
}

@end

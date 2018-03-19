//
//  XIAuthenticationInternal.mm
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XICOAuthentication.h"

#import "XIAuthentication.h"
#import "XICommonError.h"

#import <XivelySDK/XISession.h>
#import <Internals/Session/XISessionProxy.h>
#import <Internals/Session/XISessionInternal.h>
#import <Internals/Access/XIAccess.h>
#import <Internals/ServicesConfig/XIServicesConfig.h>
#import <XivelySDK/XIAuthenticationError.h>
#import "XICOBlueprintUser+AccessBlueprintUserType.h"

typedef NS_ENUM(NSInteger, XICOAuthenticationEvent) {
    XICOAuthenticationEventRequestLogin     = 1,
    XICOAuthenticationEventLoginResponse,
    XICOAuthenticationEventLoginError,
    XICOAuthenticationEventCancel,
    XICOAuthenticationEventGetEndUserSuccess,
    XICOAuthenticationEventGetEndUserError,
};

typedef NS_ENUM(NSInteger, XIAuthenticationHiddenState) {
    XIAuthenticationHiddenStateGettingUserDataForSimpleLogin = -1,
};

@interface XICOAuthentication ()
@property(strong, nonatomic) XICOFiniteStateMachine* fsm;
@property(strong, nonatomic) id<XICOLogging> log;
@property(strong, nonatomic) id<XIRESTCallProvider> restCallProvider;
@property(strong, nonatomic) XIServicesConfig* servicesConfig;
@property(weak, nonatomic)   XIAuthentication* proxy;
@property(strong, nonatomic) XIAccess* access;
@property(strong, nonatomic)id<XICOAuthenticationCall> authenticationCall;
@property(strong, nonatomic)id<XICOResolveUserCall> resolveUserCall;
@property(strong, nonatomic)NSError *error;
@end

@implementation XICOAuthentication
@synthesize delegate;
@synthesize error = _error;

-(XIAuthenticationState) state {
    switch (self.fsm.state) {
        case XIAuthenticationHiddenStateGettingUserDataForSimpleLogin:
            return XIAuthenticationStateRunning;
            
        default:
            return (XIAuthenticationState)self.fsm.state;
    }
}

-(instancetype) initWithLogger: (id<XICOLogging>) logger
              restCallProvider: (id<XIRESTCallProvider>) provider
                servicesConfig: (XIServicesConfig*) servicesConfig
                         proxy: (XIAuthentication*) proxy
                        access: (XIAccess*) access
            authenticationCall:(id<XICOAuthenticationCall>)authenticationCall
                resolveUserCall:(id<XICOResolveUserCall>)resolveUserCall {
    
    if ((self = [super init])) {
        
        self.fsm = [[XICOFiniteStateMachine alloc] initWithInitialState: XIAuthenticationStateIdle];

        // init
        [self.fsm addTransitionWithState: XIAuthenticationStateIdle
                               event: XICOAuthenticationEventRequestLogin
                              object: self
                            selector: @selector(onRequestLogin:)];
        
        // login requested
        [self.fsm addTransitionWithState: XIAuthenticationStateRunning
                               event: XICOAuthenticationEventLoginResponse
                              object: self
                            selector: @selector(onLoginResponse:)];
        [self.fsm addTransitionWithState: XIAuthenticationStateRunning
                               event: XICOAuthenticationEventLoginError
                              object: self
                            selector: @selector(onLoginError:)];
        [self.fsm addTransitionWithState: XIAuthenticationStateRunning
                               event: XICOAuthenticationEventCancel
                              object: self
                            selector: @selector(onCancel:)];
        
        // ended
        [self.fsm addTransitionWithState: XIAuthenticationStateEnded
                               event: XICOAuthenticationEventCancel
                              object: self
                            selector: @selector(onCancel:)];
        
        // error
        [self.fsm addTransitionWithState: XIAuthenticationStateError
                               event: XICOAuthenticationEventCancel
                              object: self
                            selector: @selector(onCancel:)];
        
        // GettingUserDataForSimpleLogin
        [self.fsm addTransitionWithState: XIAuthenticationHiddenStateGettingUserDataForSimpleLogin
                               event: XICOAuthenticationEventGetEndUserSuccess
                              object: self
                            selector: @selector(onGetEndUserSuccess:)];
        
        [self.fsm addTransitionWithState: XIAuthenticationHiddenStateGettingUserDataForSimpleLogin
                               event: XICOAuthenticationEventGetEndUserError
                              object: self
                            selector: @selector(onGetEndUserError:)];
        
        [self.fsm addTransitionWithState: XIAuthenticationHiddenStateGettingUserDataForSimpleLogin
                               event: XICOAuthenticationEventCancel
                              object: self
                            selector: @selector(onCancel:)];
        
        self.log                = logger;
        self.servicesConfig     = servicesConfig;
        self.proxy              = proxy;
        self.access             = access;
        self.restCallProvider = provider;
        self.authenticationCall = authenticationCall;
        self.authenticationCall.delegate = self;
        self.resolveUserCall = resolveUserCall;
        self.resolveUserCall.delegate = self;
    }
    
    return self;
}

-(void) dealloc {
    [self.authenticationCall cancel];
    [self.resolveUserCall cancel];
    
}

#pragma mark -
#pragma mark FSM transition handlers
-(NSInteger) onRequestLogin: (NSDictionary*)parameters {
    
    [self.log info: @"request login"];
    
    self.access.accountId = parameters[@"accountId"];
        
    [self.authenticationCall requestLoginWithEmailAddress:parameters[@"username"] password:parameters[@"password"] accountId:parameters[@"accountId"]];
    return XIAuthenticationStateRunning;
}

-(NSInteger) onLoginResponse: (NSDictionary*) parameters {
    
    [self.log info: @"login response"];
    self.access.jwt = parameters[@"jwt"];
    if (self.access.jwt == nil || self.access.jwt.length == 0) {
        [self.log error: @"unable to parse response:"];
        return [self returnWithError: XIErrorInternal];
    }
    
    [self.resolveUserCall requestUserWithAccountId:self.access.accountId idmUserId:self.access.idmUserId];
    return XIAuthenticationHiddenStateGettingUserDataForSimpleLogin;
}

-(NSInteger) onLoginError:(NSError *)error {
    
    [self.log info: @"login error"];
    
    return [self returnWithError: error.code];
}

-(NSInteger) onCancel: (id) object {
    [self.log info: @"cancel"];
    [self.authenticationCall cancel];
    [self.resolveUserCall cancel];
    
    return XIAuthenticationStateCanceled;
}

- (NSInteger)onGetEndUserSuccess:(XICOBlueprintUser *)user {
    self.access.blueprintUserId = user.userId;
    self.access.blueprintUserType = user.accessBlueprintUserType;
    self.access.blueprintOrganizationId = user.organizationId;
    self.access.blueprintUserName = [user.name length] ? user.name : @"";
    
    dispatch_async(dispatch_get_main_queue(), ^() { @autoreleasepool {
        if ([self.fsm state] == XIAuthenticationStateEnded) {
            [delegate authentication: self.proxy didCreateSession: [self createSession]];
        }
    }});
    return XIAuthenticationStateEnded;
}

- (NSInteger)onGetEndUserError:(NSError *)error {
    return [self returnWithError: error.code];
}

#pragma mark -
#pragma mark XICOAuthenticating

#define ADD_PARAM(parameters, x) if (x) parameters[@#x] = x;

-(void) requestSessionWithUsername: (NSString*) username
                          password: (NSString*) password
                         accountId: (NSString *)accountId {
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    ADD_PARAM(parameters, username);
    ADD_PARAM(parameters, password);
    ADD_PARAM(parameters, accountId);
    
    [self.fsm doEvent: XICOAuthenticationEventRequestLogin withObject: parameters];
}

-(void) cancel {
    [self.fsm doEvent: XICOAuthenticationEventCancel];
}

-(NSError*) errorWithAuthenticatingError: (NSUInteger) errorCode {
    return [NSError errorWithDomain: @"XICOAuthenticatingError"
                               code: errorCode
                           userInfo: nil];
}

-(XISessionProxy*) createSession {
        
    XISessionInternal* session = [[XISessionInternal alloc] initWithLogger:self.log
                                                          restCallProvider:self.restCallProvider
                                                            servicesConfig:self.servicesConfig
                                                                    access:self.access];
    XISessionProxy* sessionProxy = [[XISessionProxy alloc] initWithInternal: session];
    return sessionProxy;
}

-(XIAuthenticationState) returnWithError: (NSUInteger) error {
    
    self.error = [self errorWithAuthenticatingError: error];
    
    dispatch_async(dispatch_get_main_queue(), ^() { @autoreleasepool {
        if ([self.fsm state] == XIAuthenticationStateError) {
            [delegate authentication: self.proxy didFailWithError: self.error];
        }
    }});
    
    return XIAuthenticationStateError;
}

#pragma mark -
#pragma mark XICOAuthenticationCallDelegate
- (void)authenticationCall:(id<XICOAuthenticationCall>)authenticationCall didReceiveJwt:(NSString *)jwt {
    [self.fsm doEvent: XICOAuthenticationEventLoginResponse
           withObject: @{@"jwt": jwt ? jwt : @""}];
}

- (void)authenticationCall:(id<XICOAuthenticationCall>)authenticationCall didFailWithError:(NSError *)error {
    [self.fsm doEvent: XICOAuthenticationEventLoginError withObject: error];
}

#pragma mark -
#pragma mark XICOResolveUserCallDelegate
- (void)resolveUserCall:(id<XICOResolveUserCall>)resolveUserCall didReceiveUser:(XICOBlueprintUser *)user {
    [self.fsm doEvent:XICOAuthenticationEventGetEndUserSuccess withObject:user];
}

- (void)resolveUserCall:(id<XICOResolveUserCall>)resolveUserCall didFailWithError:(NSError *)error {
    [self.fsm doEvent:XICOAuthenticationEventGetEndUserError withObject:error];
}

@end

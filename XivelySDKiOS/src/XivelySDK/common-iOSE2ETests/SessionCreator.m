//
//  SessionCreator.m
//  common-iOS
//
//  Created by gszajko on 08/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import "SessionCreator.h"
#import "XIAuthentication.h"
#import "XISdkConfig.h"
#import "XISdkConfig+Selector.h"


@interface SessionCreator ()
@property (nonatomic, strong) XISdkConfig* config;
@property (nonatomic, strong) XIAuthentication* auth;
@property (nonatomic, weak) XCTestExpectation* sessionCreated;
@end

@implementation SessionCreator
-(instancetype) initWithEnvironment: (XIEnvironment) environment {
    if ((self = [super init])) {
        self.config = [[XISdkConfig alloc] initWithEnvironment: environment];
        self.auth = [[XIAuthentication alloc] initWithSdkConfig: self.config];
        self.auth.delegate = self;
    }
    return self;
}

- (void)dealloc {
    self.auth.delegate = nil;
}

-(void) createSessionWithUsername: (NSString*) username
                         password: (NSString*) password
                        accountId: (NSString*) accountId
                      expectation: (XCTestExpectation*) expectation {
    
    self.sessionCreated = expectation;
    [self.auth requestLoginWithUsername: username
                                password: password
                               accountId: accountId];
}

- (void)authentication:(XIAuthentication *)authentication didReceiveURL:(NSURL *)url {
    // TBD
}

- (void)authentication:(XIAuthentication *)authentication didFailWithError:(NSError *)error {
    self.session = nil;
    [self.sessionCreated fulfill];
}

- (void)authentication:(XIAuthentication *)authentication didCreateSession:(id<XISession>)session {
    self.session = session;
    [self.sessionCreated fulfill];
}
@end

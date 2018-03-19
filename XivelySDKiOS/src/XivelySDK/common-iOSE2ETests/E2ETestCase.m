//
//  E2ETestCase.m
//  common-iOS
//
//  Created by gszajko on 09/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import "E2ETestCase.h"
#import "XITestConfig.h"

@implementation E2ETestCase
- (instancetype) init {
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)setUp {
    [super setUp];
    
    self.sessionCreator = [[SessionCreator alloc] initWithEnvironment: XIEnvironmentLive];
}

- (void)tearDown {
    [super tearDown];
}

- (id<XISession>)createAccountUserSession {
    XCTestExpectation* created = [self expectationWithDescription: @"session created"];

    [self.sessionCreator createSessionWithUsername: accountUserName
                                          password: accountUserPassword
                                         accountId: accountUserAccountId
                                       expectation: created];
    [self waitForExpectationsWithTimeout: 10.f handler: nil];
    return self.sessionCreator.session;
}


- (id<XISession>)createEndUserSession {
    XCTestExpectation* created = [self expectationWithDescription: @"session created"];
    
    [self.sessionCreator createSessionWithUsername: endUserName
                                          password: endUserPassword
                                         accountId: endUserAccountId
                                       expectation: created];
    [self waitForExpectationsWithTimeout: 30.f handler: nil];
    return self.sessionCreator.session;
}
@end

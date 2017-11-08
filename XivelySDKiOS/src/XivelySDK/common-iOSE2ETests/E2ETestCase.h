//
//  E2ETestCase.h
//  common-iOS
//
//  Created by gszajko on 09/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SessionCreator.h"
#import "XISession.h"

@interface E2ETestCase : XCTestCase
@property (nonatomic, strong) SessionCreator* sessionCreator;
@property (nonatomic, strong) id<XISession> session;
- (id<XISession>)createAccountUserSession;
- (id<XISession>)createEndUserSession;

@end

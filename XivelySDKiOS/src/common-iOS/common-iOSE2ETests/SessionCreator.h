//
//  SessionCreator.h
//  common-iOS
//
//  Created by gszajko on 08/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@interface SessionCreator : NSObject<XIAuthenticationDelegate>
@property (nonatomic, strong) id<XISession> session;
-(instancetype) initWithEnvironment: (XIEnvironment) environment;
-(void) createSessionWithUsername: (NSString*) username
                         password: (NSString*) password
                        accountId: (NSString*) accountId
                      expectation: (XCTestExpectation*) expectation;
@end

//
//  XICOAuthenticating.h
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

@protocol XIAuthenticationDelegate;

@protocol XICOAuthenticating
@property(weak, nonatomic) id<XIAuthenticationDelegate> delegate;
@property(nonatomic, readonly)NSError *error;
@property(nonatomic, readonly)XIAuthenticationState state;
-(void) requestSessionWithUsername: (NSString*) username
                          password: (NSString*) password
                         accountId: (NSString*) accountId;
-(void) cancel;
@end

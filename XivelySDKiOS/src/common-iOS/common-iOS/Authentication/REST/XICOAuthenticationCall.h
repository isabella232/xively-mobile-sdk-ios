//
//  XICOAuthenticationCall.h
//  common-iOS
//
//  Created by vfabian on 30/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XICOAuthenticationCall;

@protocol XICOAuthenticationCallDelegate <NSObject>

- (void)authenticationCall:(id<XICOAuthenticationCall>)authenticationCall didReceiveJwt:(NSString *)jwt;
- (void)authenticationCall:(id<XICOAuthenticationCall>)authenticationCall didFailWithError:(NSError *)error;

@end

@protocol XICOAuthenticationCall <NSObject>

@property(nonatomic ,weak)id<XICOAuthenticationCallDelegate> delegate;

- (void)requestLoginWithEmailAddress:(NSString *)emailAddress password:(NSString *)password accountId:(NSString *)accountId;

- (void)cancel;

@end
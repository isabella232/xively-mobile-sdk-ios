//
//  XICOResolveUserCall.h
//  common-iOS
//
//  Created by vfabian on 21/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XICOBlueprintUser.h"


@protocol XICOResolveUserCall;

@protocol XICOResolveUserCallDelegate <NSObject>

- (void)resolveUserCall:(id<XICOResolveUserCall>)resolveUserCall didReceiveUser:(XICOBlueprintUser *)user;
- (void)resolveUserCall:(id<XICOResolveUserCall>)resolveUserCall didFailWithError:(NSError *)error;

@end

@protocol XICOResolveUserCall <NSObject>

@property(nonatomic ,weak)id<XICOResolveUserCallDelegate> delegate;

- (void)requestUserWithAccountId:(NSString *)accountId idmUserId:(NSString *)idmUserId;

- (void)cancel;

@end


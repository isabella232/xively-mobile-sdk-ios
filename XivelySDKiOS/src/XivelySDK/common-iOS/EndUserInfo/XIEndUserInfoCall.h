//
//  XIOrganizationInfoCall.h
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "XIDIDeviceInfoListMeta.h"
#import "XIEndUserInfo.h"

@protocol XIEndUserInfoCall;

@protocol XIEndUserInfoCallDelegate <NSObject>

- (void)endUserInfoCall:(id<XIEndUserInfoCall>)endUserInfoCall didSucceedWithEndUserInfo:(XIEndUserInfo *)endUserInfo;
- (void)endUserInfoCall:(id<XIEndUserInfoCall>)endUserInfoCall didFailWithError:(NSError *)error;

@end


@protocol XIEndUserInfoCall <NSObject>

@property(nonatomic, weak)id<XIEndUserInfoCallDelegate> delegate;

- (void)getRequestWithEndUserId:(NSString *)endUserId;
- (void)putRequestWithEndUser:(XIEndUserInfo *)endUser;

- (void)cancel;

@end

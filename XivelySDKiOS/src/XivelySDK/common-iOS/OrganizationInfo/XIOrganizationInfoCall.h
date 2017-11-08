//
//  XIOrganizationInfoCall.h
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "XIDIDeviceInfoListMeta.h"
#import "XIOrganizationInfo.h"

@protocol XIOrganizationInfoCall;

@protocol XIOrganizationInfoCallDelegate <NSObject>

- (void)organizationInfoCall:(id<XIOrganizationInfoCall>)organizationInfoCall didSucceedWithOrganizationInfo:(XIOrganizationInfo *)organizationInfo;
- (void)organizationInfoCall:(id<XIOrganizationInfoCall>)organizationInfoCall didSucceedWithOrganizationInfoList:(NSArray *)organizationInfoList;
- (void)organizationInfoCall:(id<XIOrganizationInfoCall>)organizationInfoCall didFailWithError:(NSError *)error;

@end


@protocol XIOrganizationInfoCall <NSObject>

@property(nonatomic, weak)id<XIOrganizationInfoCallDelegate> delegate;

- (void)getListRequestWithAccountId:(NSString *)accountId;
- (void)getRequestWithOrganizationId:(NSString *)organizationId;

- (void)cancel;

@end

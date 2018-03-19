//
//  XIDeviceInfoCall.h
//  common-iOS
//
//  Created by tkorodi on 10/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIDIDeviceInfoListMeta.h"
#import "XIDeviceInfo.h"

@protocol XIDeviceInfoCall;

@protocol XIDeviceInfoCallDelegate <NSObject>

- (void)deviceInfoCall:(id<XIDeviceInfoCall>)deviceInfoCall didSucceedWithDeviceInfo:(XIDeviceInfo *)deviceInfo;
- (void)deviceInfoCall:(id<XIDeviceInfoCall>)deviceInfoCall didFailWithError:(NSError *)error;

@end


@protocol XIDeviceInfoCall <NSObject>

@property(nonatomic, weak)id<XIDeviceInfoCallDelegate> delegate;

- (void)getRequestWithAccountId:(NSString *)accountId
                       deviceId:(NSString *)deviceId;

- (void)putRequestWithDeviceInfo:(XIDeviceInfo *)deviceInfo;

- (void)cancel;

@end

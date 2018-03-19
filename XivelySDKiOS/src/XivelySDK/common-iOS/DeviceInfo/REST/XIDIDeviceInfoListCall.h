//
//  XIDIDeviceInfoListCall.h
//  common-iOS
//
//  Created by vfabian on 24/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIDIDeviceInfoListMeta.h"

@protocol XIDIDeviceInfoListCall;

@protocol XIDIDeviceInfoListCallDelegate <NSObject>

- (void)deviceInfoListCall:(id<XIDIDeviceInfoListCall>)deviceInfoListCall didSucceedWithDeviceInfoList:(NSArray *)deviceInfoList meta:(XIDIDeviceInfoListMeta *)meta;
- (void)deviceInfoListCall:(id<XIDIDeviceInfoListCall>)deviceInfoListCall didFailWithError:(NSError *)error;

@end


@protocol XIDIDeviceInfoListCall <NSObject>

@property(nonatomic, weak)id<XIDIDeviceInfoListCallDelegate> delegate;

- (void)requestWithAccountId:(NSString *)accountId
              organizationId:(NSString *)organizationId
                    pageSize:(NSUInteger)pageSize
                        page:(NSUInteger)page;

- (void)requestWithAccountId:(NSString *)accountId
              organizationId:(NSString *)organizationId
                    pageSize:(NSUInteger)pageSize
                   pagesFrom:(NSUInteger)pagesFrom
                     pagesTo:(NSUInteger)pagesTo;


- (void)cancel;

@end

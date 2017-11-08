//
//  XIDADeviceAssociationCall.h
//  common-iOS
//
//  Created by vfabian on 17/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XIDADeviceAssociationCall;

@protocol XIDADeviceAssociationCallDelegate <NSObject>

- (void)deviceAssociationCall:(id<XIDADeviceAssociationCall>)deviceAssociationCall didSucceedWithDeviceId:(NSString *)deviceId;
- (void)deviceAssociationCall:(id<XIDADeviceAssociationCall>)deviceAssociationCall didFailWithError:(NSError *)error;

@end


@protocol XIDADeviceAssociationCall <NSObject>

@property(nonatomic, weak)id<XIDADeviceAssociationCallDelegate> delegate;

- (void)requestWithEndUserId:(NSString *)endUserId associationCode:(NSString *)associationCode;

- (void)cancel;

@end

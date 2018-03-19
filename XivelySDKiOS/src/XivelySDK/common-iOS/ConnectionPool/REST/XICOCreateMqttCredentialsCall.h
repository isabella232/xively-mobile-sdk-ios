//
//  XICOCreateMqttCredentialsCall.h
//  common-iOS
//
//  Created by vfabian on 03/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XICOCreateMqttCredentialsCall;

@protocol XICOCreateMqttCredentialsCallDelegate

- (void)createMqttCredentialsCall:(id<XICOCreateMqttCredentialsCall>)createMqttCredentialsCall
       didSucceedWithMqttUserName:(NSString *)mqttUserName
                     mqttPassword:(NSString *)mqttPassword;

- (void)createMqttCredentialsCall:(id<XICOCreateMqttCredentialsCall>)createMqttCredentialsCall didFailWithError:(NSError *)error;


@end

@protocol XICOCreateMqttCredentialsCall <NSObject>

@property(nonatomic, weak)id<XICOCreateMqttCredentialsCallDelegate> delegate;

- (void)requestWithEndUserId:(NSString *)endUserId accountId:(NSString *)accountId;

- (void)requestWithAccountUserId:(NSString *)accountUserId accountId:(NSString *)accountId;

- (void)cancel;


@end

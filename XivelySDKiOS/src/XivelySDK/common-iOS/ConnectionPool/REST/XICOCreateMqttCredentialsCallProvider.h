//
//  XICOCreateMqttCredentialsCallProvider.h
//  common-iOS
//
//  Created by vfabian on 03/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XICOCreateMqttCredentialsCall.h"

@protocol XICOCreateMqttCredentialsCallProvider <NSObject>

- (id<XICOCreateMqttCredentialsCall>)createMqttCredentialsCall;

@end

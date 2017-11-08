//
//  XICOAuthenticationRestCall.h
//  common-iOS
//
//  Created by vfabian on 30/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XICOAuthenticationCall.h"

@interface XICOAuthenticationRestCall : NSObject <XICOAuthenticationCall, XIRESTCallDelegate>

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig;

@end

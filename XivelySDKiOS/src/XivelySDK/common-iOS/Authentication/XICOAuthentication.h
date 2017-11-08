//
//  XIAuthenticationInternal.h
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XICOAuthenticationCall.h"
#import "XICOResolveUserCall.h"


@class XIAuthentication;
@class XIServicesConfig;
@class XIAccess;

@interface XICOAuthentication : NSObject<XICOAuthenticating, XICOAuthenticationCallDelegate, XICOResolveUserCallDelegate>
-(instancetype) initWithLogger: (id<XICOLogging>) logger
              restCallProvider: (id<XIRESTCallProvider>) provider
                servicesConfig: (XIServicesConfig*) servicesConfig
                         proxy: (XIAuthentication*) proxy
                        access: (XIAccess*) access
            authenticationCall:(id<XICOAuthenticationCall>)authenticationCall
               resolveUserCall:(id<XICOResolveUserCall>)resolveUserCall;
@end

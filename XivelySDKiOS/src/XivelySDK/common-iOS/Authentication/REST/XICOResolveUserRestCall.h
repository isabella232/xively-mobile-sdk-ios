//
//  XICOResolveUserRestCall.h
//  common-iOS
//
//  Created by vfabian on 21/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XICOResolveUserCall.h"

@interface XICOResolveUserRestCall : NSObject <XICOResolveUserCall, XIRESTCallDelegate>

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig;


@end

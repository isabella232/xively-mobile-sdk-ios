//
//  XIOrganizationInfoRestCall.h
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIOrganizationInfoCall.h"

@interface XIOrganizationInfoRestCall : NSObject <XIOrganizationInfoCall, XIRESTCallDelegate>

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig;

@end

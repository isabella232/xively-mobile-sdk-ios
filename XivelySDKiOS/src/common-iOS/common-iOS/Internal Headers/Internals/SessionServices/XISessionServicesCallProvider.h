//
//  XISessionServicesCallProvider.h
//  common-iOS
//
//  Created by vfabian on 05/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XISessionServicesCallProvider <NSObject>

- (id)initWithLogger:(id<XICOLogging>)logger restCallProvider:(id<XIRESTCallProvider>)provider servicesConfig:(XIServicesConfig *)servicesConfig;

@end

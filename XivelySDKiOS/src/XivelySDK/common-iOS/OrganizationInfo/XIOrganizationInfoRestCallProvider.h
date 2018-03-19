//
//  XIOrganizationInfoRestCallProvider.h
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIOrganizationInfoCallProvider.h"
#import <Internals/SessionServices/XISessionServicesCallProvider.h>

@interface XIOrganizationInfoRestCallProvider : NSObject <XIOrganizationInfoCallProvider, XISessionServicesCallProvider>

@end

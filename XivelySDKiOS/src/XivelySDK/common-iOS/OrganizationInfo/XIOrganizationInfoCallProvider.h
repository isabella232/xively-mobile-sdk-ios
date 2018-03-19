//
//  XIOrganizationInfoCallProvider.h
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIOrganizationInfoCall.h"

@protocol XIOrganizationInfoCallProvider <NSObject>

- (id<XIOrganizationInfoCall>)organizationInfoCall;

@end

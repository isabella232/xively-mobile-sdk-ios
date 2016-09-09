//
//  XIOROrganizationHandler.h
//  common-iOS
//
//  Created by tkorodi on 18/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/OrganizationInfo/XIOrganizationHandler.h>
#import "XIOrganizationInfoCallProvider.h"
#import <Internals/SessionServices/XISessionServiceWithCallProvider.h>

@interface XIOROrganizationHandler : NSObject <XIOrganizationHandler, XIOrganizationInfoCallDelegate, XISessionServiceWithCallProvider>

@end

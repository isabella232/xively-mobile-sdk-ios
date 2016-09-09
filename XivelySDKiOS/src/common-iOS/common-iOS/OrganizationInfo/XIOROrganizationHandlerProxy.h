//
//  XIOROrganizationHandlerProxy.h
//  common-iOS
//
//  Created by tkorodi on 19/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/OrganizationInfo/XIOrganizationHandler.h>
#import <Internals/SessionServices/XISessionServiceProxy.h>

@interface XIOROrganizationHandlerProxy : NSObject <XIOrganizationHandler, XISessionServiceProxy>

@end

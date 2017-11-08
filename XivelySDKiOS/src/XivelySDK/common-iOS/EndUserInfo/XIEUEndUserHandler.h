//
//  XIOROrganizationHandler.h
//  common-iOS
//
//  Created by tkorodi on 18/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/EndUserInfo/XIEndUserHandler.h>
#import "XIEndUserInfoCallProvider.h"
#import <Internals/SessionServices/XISessionServiceWithCallProvider.h>

@interface XIEUEndUserHandler : NSObject <XIEndUserHandler, XIEndUserInfoCallDelegate, XISessionServiceWithCallProvider>

@end

//
//  XIOROrganizationHandlerProxy.h
//  common-iOS
//
//  Created by tkorodi on 19/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/EndUserInfo/XIEndUserHandler.h>
#import <Internals/SessionServices/XISessionServiceProxy.h>

@interface XIEUEndUserHandlerProxy : NSObject <XIEndUserHandler, XISessionServiceProxy>

@end

//
//  XIAccess+XIRESTDefaultHeadersProvider.h
//  common-iOS
//
//  Created by vfabian on 21/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIAccess.h"
#import <Internals/RESTCall/XIRESTDefaultHeadersProvider.h>

@interface XIAccess (XIRESTDefaultHeadersProvider) <XIRESTDefaultHeadersProviderJwtSource>

@end

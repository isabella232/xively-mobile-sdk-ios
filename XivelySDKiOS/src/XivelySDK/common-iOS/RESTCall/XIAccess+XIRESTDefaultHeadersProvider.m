//
//  XIAccess+XIRESTDefaultHeadersProvider.m
//  common-iOS
//
//  Created by vfabian on 21/07/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Internals/RESTCall/XIAccess+XIRESTDefaultHeadersProvider.h>

@implementation XIAccess (XIRESTDefaultHeadersProvider)

- (NSString *)jwtString {
    return self.jwt;
}

@end

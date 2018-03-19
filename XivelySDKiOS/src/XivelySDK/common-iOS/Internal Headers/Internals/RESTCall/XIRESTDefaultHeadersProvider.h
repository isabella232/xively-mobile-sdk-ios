//
//  XIRESTDefaultHeadersProvider.h
//  common-iOS
//
//  Created by vfabian on 21/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XIRESTDefaultHeadersProviderJwtSource <NSObject>

- (NSString *)jwtString;

@end

@interface XIRESTDefaultHeadersProvider : NSObject

- (instancetype)initWithJwtSource:(id<XIRESTDefaultHeadersProviderJwtSource>)jwtSource;

- (NSDictionary *)defaultHeaders;
- (NSString*)jwt;

@end

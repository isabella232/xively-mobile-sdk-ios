//
//  XIAccess.m
//  common-iOS
//
//  Created by vfabian on 14/01/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIAccess.h"
#import "XISdkConfig.h"

/** @file */

/**
 * @brief XIAccess private interface.
 * @since Version 1.0
 */
@interface XIAccess ()
@end

@implementation XIAccess
@synthesize idmUserId = _idmUserId;

- (NSString *)mqttUsername {
    return [self.blueprintUserId copy];
}

- (void)setJwt:(NSString *)jwt {
    _jwt = [jwt copy];
    _idmUserId = [self getEndUserIdFromJwt:_jwt];
}

- (NSString *)getEndUserIdFromJwt:(NSString *)jwt {
    NSArray *jwtComponents = [jwt componentsSeparatedByString:@"."];
    if(jwtComponents.count < 3) return nil;
    
    NSString *dataComponent = jwtComponents[1];
    NSData *decodedData = nil;
    
    int tryCount = 0;
    const int maxTryCount = 6;
    
    while ( ! (decodedData = [[NSData alloc] initWithBase64EncodedString:dataComponent options:0]) && tryCount++ < maxTryCount) {
        dataComponent = [NSString stringWithFormat:@"%@=",dataComponent];
    }
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:decodedData options:0 error:&error];
    
    return dict[@"userId"];
}

@end

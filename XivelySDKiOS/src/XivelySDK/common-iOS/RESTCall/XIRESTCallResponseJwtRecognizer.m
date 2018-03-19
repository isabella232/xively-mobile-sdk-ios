//
//  XIRESTCallResponseRecognizer.m
//  common-iOS
//
//  Created by vfabian on 04/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIRESTCallResponseJwtRecognizer.h"
#import <Internals/RESTCall/XIRESTCallResponseJwtRecognizer.h>

@implementation XIRESTCallResponseJwtRecognizer

@synthesize delegate;

#pragma mark -
#pragma mark XIRESTCallResponseRecognizer
- (void)handleUrlResponse:(NSURLResponse *)response {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *jwt = httpResponse.allHeaderFields[@"xively-access-token"];
    if (jwt) {
        [self.delegate restCallResponseJwtRecognizer:self didRecognizeJwt:jwt];
    }
}

@end

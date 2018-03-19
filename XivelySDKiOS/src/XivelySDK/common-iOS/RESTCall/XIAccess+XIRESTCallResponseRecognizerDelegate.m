//
//  XIAccess+XIRESTCallResponseRecognizerDelegate.m
//  common-iOS
//
//  Created by vfabian on 04/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIAccess+XIRESTCallResponseRecognizerDelegate.h"


@implementation XIAccess (XIRESTCallResponseRecognizerDelegate)

- (void)restCallResponseJwtRecognizer:(XIRESTCallResponseJwtRecognizer *)jwtRecognizer didRecognizeJwt:(NSString *)jwt {
    self.jwt = jwt;
}

@end

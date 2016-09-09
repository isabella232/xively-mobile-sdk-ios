//
//  XIRESTCallResponseRecognizer.h
//  common-iOS
//
//  Created by vfabian on 04/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XIRESTCallResponseRecognizer <NSObject>

- (void)handleUrlResponse:(NSURLResponse *)response;

@end

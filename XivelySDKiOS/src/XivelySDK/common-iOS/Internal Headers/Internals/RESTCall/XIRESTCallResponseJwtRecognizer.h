//
//  XIRESTCallResponseJwtRecognizer.h
//  common-iOS
//
//  Created by vfabian on 04/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Internals/RESTCall/XIRESTCallResponseRecognizer.h>

@class XIRESTCallResponseJwtRecognizer;


@protocol XIRESTCallResponseJwtRecognizerDelegate <NSObject>

- (void)restCallResponseJwtRecognizer:(XIRESTCallResponseJwtRecognizer *)jwtRecognizer didRecognizeJwt:(NSString *)jwt;

@end

@interface XIRESTCallResponseJwtRecognizer : NSObject <XIRESTCallResponseRecognizer>

@property(nonatomic, weak)id<XIRESTCallResponseJwtRecognizerDelegate> delegate;

@end

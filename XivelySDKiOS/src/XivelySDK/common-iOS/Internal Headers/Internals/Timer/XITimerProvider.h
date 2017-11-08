//
//  XITimerProvider.h
//  common-iOS
//
//  Created by vfabian on 13/02/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XITimer;

@protocol XITimerProvider <NSObject>

- (id<XITimer>)getTimer;

@end


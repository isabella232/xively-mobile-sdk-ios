//
//  XISessionProxy.m
//  common-iOS
//
//  Created by vfabian on 14/01/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

/** @file */

#import "XISessionProxy.h"
#import "XISessionInternal.h"
#import "XISession.h"
#import "XICommonError.h"

/**
 * @brief XISessionProxy private interface.
 * @since Version 1.0
 */
@interface XISessionProxy (){
    @private
    XISessionInternal *_internal;
}
@end

@implementation XISessionProxy

- (XISessionState)state {
    return _internal.state;
}

- (BOOL)suspended {
    return _internal.suspended;
}

- (XISessionServices *)services {
    return _internal.services;
}

+ (instancetype)sessionWithInternal:(XISessionInternal *)internalSession {
    return [[[self class] alloc] initWithInternal:internalSession];
}

- (instancetype)initWithInternal:(XISessionInternal *)internalSession {
    self = [super init];
    if (self) {
        _internal = internalSession;
        _internal.delegateCaller = self;
    }
    
    return self;
}

- (void)close {
    [_internal close];
}

- (void)suspend {
    [_internal suspend];
}

- (void)resume {
    [_internal resume];
}

- (void)logout {
    [_internal logout];
}

#pragma mark -
#pragma mark Memory management
- (void) dealloc {
    
}

@end

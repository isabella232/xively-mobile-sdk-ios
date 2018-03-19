//
//  XIRESTDefaultHeadersProvider.m
//  common-iOS
//
//  Created by vfabian on 21/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XIRESTDefaultHeadersProvider.h"

@interface XIRESTDefaultHeadersProvider () {
    id<XIRESTDefaultHeadersProviderJwtSource> _jwtSource;
}

@end

@implementation XIRESTDefaultHeadersProvider

- (instancetype)initWithJwtSource:(id<XIRESTDefaultHeadersProviderJwtSource>)jwtSource {
    self = [super init];
    if (self) {
        _jwtSource = jwtSource;
    }
    return self;
}

- (NSDictionary *)defaultHeaders {
    if (_jwtSource.jwtString.length) {
        return @{@"Content-Type" : @"application/json; charset=utf-8",
                 @"Authorization" : [NSString stringWithFormat:@"Bearer %@",_jwtSource.jwtString]};
    } else {
        return @{@"Content-Type" : @"application/json; charset=utf-8"};
    }
}

- (NSString*)jwt {
    return _jwtSource.jwtString;
}

- (void)setJwtSource:(id<XIRESTDefaultHeadersProviderJwtSource>)source {
    _jwtSource = source;
}

@end

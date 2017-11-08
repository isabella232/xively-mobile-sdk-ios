//
//  XIOrganizationInfoMeta.m
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import "XIEndUserInfoMeta.h"

#define ValueOrNil(key) ( ( dictionary[key] != [NSNull null] ) ? [dictionary[key] copy] : nil )

@implementation XIEndUserInfoMeta

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.count = [ValueOrNil(@"count") unsignedIntegerValue];
        self.page = [ValueOrNil(@"page") unsignedIntegerValue];
        self.pageSize = [ValueOrNil(@"pageSize") unsignedIntegerValue];
        self.sortOrder = ValueOrNil(@"sortOrder");
    }
    return self;
}


@end

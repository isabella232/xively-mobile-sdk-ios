//
//  XIOrganizationInfoMeta.m
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 Xively All rights reserved.
//

#import "XIOrganizationInfoMeta.h"

#define ValueOrNil(key) ( ( dictionary[key] != [NSNull null] ) ? [dictionary[key] copy] : nil )

@implementation XIOrganizationInfoMeta

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

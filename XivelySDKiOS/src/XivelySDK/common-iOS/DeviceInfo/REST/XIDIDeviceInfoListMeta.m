//
//  XIDIDeviceInfoListMeta.m
//  common-iOS
//
//  Created by vfabian on 24/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIDIDeviceInfoListMeta.h"

#define ValueOrNil(key) ( ( dictionary[key] != [NSNull null] ) ? [dictionary[key] copy] : nil )

@implementation XIDIDeviceInfoListMeta

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

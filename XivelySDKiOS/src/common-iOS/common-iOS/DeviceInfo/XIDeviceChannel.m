//
//  XIDeviceChannel.m
//  common-iOS
//
//  Created by vfabian on 24/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIDeviceChannel.h"
#import "XIDeviceChannel+InitWithDictionary.h"

#define ValueOrNil(key) ( ( dictionary[key] != [NSNull null] ) ? [dictionary[key] copy] : nil )

@implementation XIDeviceChannel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _parameters = [dictionary copy];
        _channelId = ValueOrNil(@"channel");
        //timeSeries
        NSString *persitanceType = ValueOrNil(@"persistenceType");
        if ([persitanceType isEqualToString:@"timeSeries"]) {
            _persistenceType = XIDeviceChannelPersistanceTypeTimeSeries;
        } else if ([persitanceType isEqualToString:@"simple"]) {
            _persistenceType = XIDeviceChannelPersistanceTypeSimple;
        }
    }
    return self;
}

@end

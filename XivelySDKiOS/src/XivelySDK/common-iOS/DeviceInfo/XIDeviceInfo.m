//
//  XIDeviceInfo.m
//  common-iOS
//
//  Created by vfabian on 24/08/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <XivelySDK/DeviceInfo/XIDeviceInfo.h>
#import "XIDeviceInfo+InitWithDictionary.h"
#import <XivelySDK/DeviceInfo/XIDeviceChannel.h>
#import "XIDeviceChannel+InitWithDictionary.h"

#define ValueOrNil(key) ( ( dictionary[key] != [NSNull null] ) ? [dictionary[key] copy] : nil )

@implementation XIDeviceInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _parameters = [dictionary copy];
		_customFields = _parameters;
        
        _deviceId = ValueOrNil(@"id");
        _organizationId = ValueOrNil(@"organizationId");
        _serialNumber = ValueOrNil(@"serialNumber");
        _deviceVersion =  ValueOrNil(@"deviceVersion");
        _deviceLocation =  ValueOrNil(@"location");
        _deviceName =  ValueOrNil(@"name");
        _version = ValueOrNil(@"version");
        
        NSString *purchaseDateString = ValueOrNil(@"purchaseDate");
        if (purchaseDateString) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setLenient:YES];
            [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            _purchaseDate = [formatter dateFromString:purchaseDateString];
        }
        
        NSString *provisiningStateString = ValueOrNil(@"provisioningState");
        if ([provisiningStateString isEqualToString:@"defined"]) {
            _provisioningState = XIDeviceInfoProvisioningStateDefined;
        } else if ([provisiningStateString isEqualToString:@"activated"]) {
            _provisioningState = XIDeviceInfoProvisioningStateActivated;
        } else if ([provisiningStateString isEqualToString:@"associated"]) {
            _provisioningState = XIDeviceInfoProvisioningStateAssociated;
        } else if ([provisiningStateString isEqualToString:@"reserved"]) {
            _provisioningState = XIDeviceInfoProvisioningStateReserved;
        }

        NSMutableArray *channels = [NSMutableArray new];
        NSArray *channelDicts = ValueOrNil(@"channels");
        for (NSDictionary *dict in channelDicts) {
            XIDeviceChannel *channel = [[XIDeviceChannel alloc] initWithDictionary:dict];
            [channels addObject:channel];
        }
        _deviceChannels = [channels copy];
    }
    return self;
}

- (NSDictionary*)dictionary {
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];

	if ( _fieldsToUpdate != nil ) [ dictionary addEntriesFromDictionary: _fieldsToUpdate ];
    
    if (_deviceId) [dictionary setObject:_deviceId forKey:@"id"];
    if (_organizationId) [dictionary setObject:_organizationId forKey:@"organizationId"];
    if (_serialNumber) [dictionary setObject:_serialNumber forKey:@"serialNumber"];
    if (_deviceVersion) [dictionary setObject:_deviceVersion forKey:@"deviceVersion"];
    if (_deviceLocation) [dictionary setObject:_deviceLocation forKey:@"location"];
    if (_deviceName) [dictionary setObject:_deviceName forKey:@"name"];
    
    if (_purchaseDate) [dictionary setObject:_purchaseDate forKey:@"purchaseDate"];
    
    return dictionary;
}


@end

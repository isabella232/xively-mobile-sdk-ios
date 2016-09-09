//
//  XIOrganizationInfo.m
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/EndUserInfo/XIEndUserInfo.h>
#import "XIEndUserInfo+InitWithDictionary.h"

#define ValueOrNil(key) ( ( dictionary[key] != [NSNull null] ) ? [dictionary[key] copy] : nil )

@implementation XIEndUserInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _parameters = [dictionary copy];
		_customFields = _parameters;
        
        _endUserId = ValueOrNil(@"id");
        _version = ValueOrNil(@"version");
        _name = ValueOrNil(@"name");
        _phoneNumber = ValueOrNil(@"phoneNumber");
        _address = ValueOrNil(@"address");
        _emailAddress = ValueOrNil(@"emailAddress");
        _city = ValueOrNil(@"city");
        _state = ValueOrNil(@"state");
        _postalCode = ValueOrNil(@"postalCode");
        _countryCode = ValueOrNil(@"countryCode");
    }
    return self;
}

- (NSDictionary*)dictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

	if ( _fieldsToUpdate != nil ) [ dict addEntriesFromDictionary: _fieldsToUpdate ];

    if (_endUserId) dict[@"id"] = _endUserId;
    if (_version) dict[@"version"] = _version;
    if (_name) dict[@"name"] = _name;
    if (_phoneNumber) dict[@"phoneNumber"] = _phoneNumber;
    if (_address) dict[@"address"] = _address;
    if (_emailAddress) dict[@"emailAddress"] = _emailAddress;
    if (_city) dict[@"city"] = _city;
    if (_state) dict[@"state"] = _state;
    if (_postalCode) dict[@"postalCode"] = _postalCode;
    if (_countryCode) dict[@"countryCode"] = _countryCode;
    return dict;
}

@end

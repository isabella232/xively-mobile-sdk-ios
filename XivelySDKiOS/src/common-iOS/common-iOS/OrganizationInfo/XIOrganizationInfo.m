//
//  XIOrganizationInfo.m
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/OrganizationInfo/XIOrganizationInfo.h>
#import "XIOrganizationInfo+InitWithDictionary.h"

#define ValueOrNil(key) ( ( dictionary[key] != [NSNull null] ) ? [dictionary[key] copy] : nil )

@implementation XIOrganizationInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _parameters = [dictionary copy];
		_customFields = _parameters;
        
        _organizationId = ValueOrNil(@"id");
        _parentId = ValueOrNil(@"parentId");
        _version = ValueOrNil(@"version");
        _name = ValueOrNil(@"name");
        _desc = ValueOrNil(@"description");
        _phoneNumber = ValueOrNil(@"phoneNumber");
        _address = ValueOrNil(@"address");
        _city = ValueOrNil(@"city");
        _state = ValueOrNil(@"state");
        _postalCode = ValueOrNil(@"postalCode");
        _countryCode = ValueOrNil(@"countryCode");
        _industry = ValueOrNil(@"industry");
        _organizationSize = ValueOrNil(@"organizationSize");
        _websiteAddress = ValueOrNil(@"websiteAddress");
    }
    return self;
}

- (NSDictionary*)dictionary {
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];

	if ( _fieldsToUpdate != nil ) [ dictionary addEntriesFromDictionary: _fieldsToUpdate ];    
    return dictionary;
}

@end

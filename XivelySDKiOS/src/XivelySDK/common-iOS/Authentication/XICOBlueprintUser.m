//
//  XICOBlueprintUser.m
//  common-iOS
//
//  Created by vfabian on 21/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import "XICOBlueprintUser.h"

@implementation XICOBlueprintUser

- (instancetype)initWithUserType:(XICOBlueprintUserType)userType Dictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.userType = userType;
        [self initByDictionary:dictionary];
    }
    return self;
}

- (void)initByDictionary:(NSDictionary *)dictionary {
    self.userId = [dictionary[@"id"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"id"];
    self.accountId = [dictionary[@"accountId"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"accountId"];
    self.organizationId = [dictionary[@"organizationId"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"organizationId"];
    self.accessUserId = [dictionary[@"userId"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"userId"];
    self.address = [dictionary[@"address"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"address"];
    self.city = [dictionary[@"city"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"city"];
    self.countryCode = [dictionary[@"countryCode"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"countryCode"];
    self.emailAddress = [dictionary[@"emailAddress"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"emailAddress"];
    self.name = [dictionary[@"name"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"name"];
    self.phoneNumber = [dictionary[@"phoneNumber"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"phoneNumber"];
    self.postalCode = [dictionary[@"postalCode"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"postalCode"];
    self.state = [dictionary[@"state"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"state"];
}

@end

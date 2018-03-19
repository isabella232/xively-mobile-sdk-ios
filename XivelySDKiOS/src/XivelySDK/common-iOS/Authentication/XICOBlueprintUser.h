//
//  XICOBlueprintUser.h
//  common-iOS
//
//  Created by vfabian on 21/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XICOBlueprintUserType) {
    XICOBlueprintUserTypeUndefined,
    XICOBlueprintUserTypeAccountUser,
    XICOBlueprintUserTypeEndUser
};

@interface XICOBlueprintUser : NSObject

@property(nonatomic, assign)XICOBlueprintUserType userType;
@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *accountId;
@property(nonatomic, strong)NSString *organizationId;
@property(nonatomic, strong)NSString *accessUserId;

@property(nonatomic, strong)NSString *address;
@property(nonatomic, strong)NSString *city;
@property(nonatomic, strong)NSString *countryCode;
@property(nonatomic, strong)NSString *emailAddress;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *phoneNumber;
@property(nonatomic, strong)NSString *postalCode;
@property(nonatomic, strong)NSString *state;

- (instancetype)initWithUserType:(XICOBlueprintUserType)userType Dictionary:(NSDictionary *)dictionary;

@end

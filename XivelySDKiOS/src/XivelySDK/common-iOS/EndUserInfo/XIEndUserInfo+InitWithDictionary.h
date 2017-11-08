//
//  XIOrganizationInfo+InitWithDictionary.h
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import "XIEndUserInfo.h"

@interface XIEndUserInfo (InitWithDictionary)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary*)dictionary;

@end

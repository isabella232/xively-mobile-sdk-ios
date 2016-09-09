//
//  XIDeviceInfo+InitWithDictionary.h
//  common-iOS
//
//  Created by vfabian on 24/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XIDeviceInfo.h"

@interface XIDeviceInfo (InitWithDictionary)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary*)dictionary;

@end

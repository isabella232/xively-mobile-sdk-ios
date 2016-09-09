//
//  XIDIDeviceInfoListMeta.h
//  common-iOS
//
//  Created by vfabian on 24/08/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XIDIDeviceInfoListMeta : NSObject

@property(nonatomic, assign)NSUInteger count;
@property(nonatomic, assign)NSUInteger page;
@property(nonatomic, assign)NSUInteger pageSize;
@property(nonatomic, strong)NSString *sortOrder;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

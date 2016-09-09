//
//  XIOrganizationInfoMeta.h
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XIOrganizationInfoMeta : NSObject

@property(nonatomic, assign)NSUInteger count;
@property(nonatomic, assign)NSUInteger page;
@property(nonatomic, assign)NSUInteger pageSize;
@property(nonatomic, strong)NSString *sortOrder;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

//
//  XISessionServiceWithSessionInternal.h
//  common-iOS
//
//  Created by vfabian on 05/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XISessionServiceWithSessionInternal <NSObject>

@property(nonatomic, weak)id proxy;

- (id)initWithSession:(XISessionInternal *)sessionInternal;

@end

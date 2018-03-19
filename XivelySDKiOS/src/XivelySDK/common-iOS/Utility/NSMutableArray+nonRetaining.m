//
//  NSMutableArray+nonRetaining.m
//  Copyright (c) 2014 Xively All rights reserved.
//

#import "NSMutableArray+nonRetaining.h"

@implementation NSMutableArray (XINonRetaining)

+ (id)XIMutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    // We create a weak reference array
    return (__bridge_transfer id)(CFArrayCreateMutable(0, capacity, &callbacks));
}


+ (id)XINonRetainingArrayWithCapacity:(NSUInteger)itemNum {
    return [self XIMutableArrayUsingWeakReferencesWithCapacity:itemNum];
}

@end

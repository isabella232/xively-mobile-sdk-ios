//
//  NSString+XISecureTopicName.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Utility/NSString+XIURLEncode.h>
#import "NSString+XISecureTopicName.h"

@implementation NSString (XISecureTopicName)

- (NSString *)xiconvertTopicNameForUrl {
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
                                                                        kCFAllocatorDefault,
                                                                        (CFStringRef)self,
                                                                        NULL,
                                                                        CFSTR(":?#[]@!$&'()*+,;="),
                                                                        kCFStringEncodingUTF8);

    return (__bridge_transfer NSString *)encodedString;
}

@end

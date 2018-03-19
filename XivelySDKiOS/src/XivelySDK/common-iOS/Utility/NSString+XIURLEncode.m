//
//  NSString+XIURLEncode.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "NSString+XIURLEncode.h"

@implementation NSString (XIURLEncode)

//by https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/WorkingwithURLEncoding/WorkingwithURLEncoding.html
- (NSString *)xiUrlEncode {
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
                                                                        kCFAllocatorDefault,
                                                                        (CFStringRef)self,
                                                                        NULL,
                                                                        CFSTR(":/?#[]@!$&'()*+,;="),
                                                                        kCFStringEncodingUTF8);
    
    return (__bridge_transfer NSString *)encodedString;
}

@end

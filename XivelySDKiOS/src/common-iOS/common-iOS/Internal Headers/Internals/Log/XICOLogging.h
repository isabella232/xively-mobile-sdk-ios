//
//  XICOLogging.h
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#ifndef common_iOS_XICOLogging_h
#define common_iOS_XICOLogging_h

@protocol XICOLogging
-(void) trace: (NSString*) fmt, ...;
-(void) debug: (NSString*) fmt, ...;
-(void) info: (NSString*) fmt, ...;
-(void) warning: (NSString*) fmt, ...;
-(void) error: (NSString*) fmt, ...;
@end

#endif

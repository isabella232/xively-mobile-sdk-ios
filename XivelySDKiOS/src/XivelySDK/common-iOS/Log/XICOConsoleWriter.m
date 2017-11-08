//
//  XICOConsoleWriter.m
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XICOConsoleWriter.h"

@implementation XICOConsoleWriter
-(void) logWithFacility: (NSString*) facility
                  level: (XILogLevel) level
                message: (NSString*) message {
    
    NSLog(@"%@ - %@ - %@", facility,
          [self levelToString: level],
          message);
}

-(NSString*) levelToString: (XILogLevel) level {
    switch (level) {
        case XILogLevelTrace:     return @"[ T ]";
        case XILogLevelDebug:     return @"[ D ]";
        case XILogLevelInfo:      return @"[ I ]";
        case XILogLevelWarning:   return @"[ W ]";
        case XILogLevelError:     return @"[ E ]";
    }
}
@end

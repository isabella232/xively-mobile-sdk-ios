//
//  XICOLogger.m
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import "XICOLogger.h"
#import "XICOLoggerFacility.h"
#import "XICOConsoleWriter.h"

@interface XICOLogger ()
@property (strong, nonatomic) NSMutableSet* writers;
@end

@implementation XICOLogger
// @synthesize level;

+(XICOLogger*)sharedLogger {
    static XICOLogger* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(instancetype) init {
    if ((self = [super init])) {
        _writers = [[NSMutableSet alloc] init];
        _level = XILogLevelTrace;
        [self registerLogWriter: [[XICOConsoleWriter alloc] init]];
    }
    return self;
}

-(id<XICOLogging>) createLoggerWithFacility: (NSString*) facility {
    
    return [[XICOLoggerFacility alloc] initWithFacility: facility];
}

-(void) logWithFacility: (NSString*) facility
                  level: (XILogLevel) level
                message: (NSString*) message {
    
    if (level < _level)
        return;
    
    for (id<XICOLogWriting> writer in _writers) {
        
        [writer logWithFacility: facility
                          level: level
                        message: message];
    }
}

-(void) registerLogWriter: (id<XICOLogWriting>) writer {
    
    [_writers addObject: writer];
}
@end

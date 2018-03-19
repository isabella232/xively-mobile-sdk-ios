//
//  XICOLoggerFacility.m
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XICOLoggerFacility.h"

@interface XICOLoggerFacility ()
@property (strong, nonatomic) NSString* facility;
@end

@implementation XICOLoggerFacility
-(instancetype) initWithFacility: (NSString*) facility {
    if ((self = [super init])) {
        _facility = facility;
    }
    return self;
}

-(void) trace: (NSString*) fmt, ... {
    
    va_list arg;
    va_start(arg, fmt);
    NSString* message = [[NSString alloc] initWithFormat: fmt arguments: arg];
    [[XICOLogger sharedLogger] logWithFacility: _facility level: XILogLevelTrace message:message];
    va_end(arg);
}

-(void) debug: (NSString*) fmt, ... {
    
    va_list arg;
    va_start(arg, fmt);
    NSString* message = [[NSString alloc] initWithFormat: fmt arguments: arg];
    [[XICOLogger sharedLogger] logWithFacility: _facility level: XILogLevelDebug message:message];
    va_end(arg);
}

-(void) info: (NSString*) fmt, ... {
    
    va_list arg;
    va_start(arg, fmt);
    NSString* message = [[NSString alloc] initWithFormat: fmt arguments: arg];
    [[XICOLogger sharedLogger] logWithFacility: _facility level: XILogLevelInfo message:message];
    va_end(arg);
}

-(void) warning: (NSString*) fmt, ... {
    
    va_list arg;
    va_start(arg, fmt);
    NSString* message = [[NSString alloc] initWithFormat: fmt arguments: arg];
    [[XICOLogger sharedLogger] logWithFacility: _facility level: XILogLevelWarning message:message];
    va_end(arg);
}

-(void) error: (NSString*) fmt, ... {
    
    va_list arg;
    va_start(arg, fmt);
    NSString* message = [[NSString alloc] initWithFormat: fmt arguments: arg];
    [[XICOLogger sharedLogger] logWithFacility: _facility level: XILogLevelError message:message];
    va_end(arg);
}
@end

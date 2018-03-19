//
//  XICOLogger.h
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XICOLogger : NSObject
@property (nonatomic) XILogLevel level;

+(XICOLogger*)sharedLogger;
-(id<XICOLogging>) createLoggerWithFacility: (NSString*) facility;
-(void) logWithFacility: (NSString*) facility
                  level: (XILogLevel) level
                message: (NSString*) message;
-(void) registerLogWriter: (id<XICOLogWriting>) writer;
@end

//
//  XICOLogWriting.h
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#ifndef common_iOS_XICOLogWriting_h
#define common_iOS_XICOLogWriting_h

@protocol XICOLogWriting
-(void) logWithFacility: (NSString*) facility
                  level: (XILogLevel) level
                message: (NSString*) message;
@end

#endif

//
//  XICOLoggerFacility.h
//  common-iOS
//
//  Created by gszajko on 29/06/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XICOLoggerFacility : NSObject<XICOLogging>
-(instancetype) initWithFacility: (NSString*) facility;
@end

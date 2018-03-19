//
//  XITSTimeSeriesCallProvider.h
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XITSTimeSeriesCall.h"

@protocol XITSTimeSeriesCallProvider <NSObject>

- (id<XITSTimeSeriesCall>)timeSeriesCall;

@end

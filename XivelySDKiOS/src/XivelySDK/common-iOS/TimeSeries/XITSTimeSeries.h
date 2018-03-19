//
//  XITSTimeSeries.h
//  common-iOS
//
//  Created by vfabian on 15/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/TimeSeries/XITimeSeries.h>
#import "XITSTimeSeriesCallProvider.h"
#import <Internals/SessionServices/XISessionServiceWithCallProvider.h>

@interface XITSTimeSeries : NSObject <XITimeSeries, XITSTimeSeriesCallDelegate, XISessionServiceWithCallProvider>

@end

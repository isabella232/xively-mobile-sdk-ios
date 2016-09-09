//
//  XITimeSeriesProxy.h
//  common-iOS
//
//  Created by vfabian on 15/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/TimeSeries/XITimeSeries.h>
#import <Internals/SessionServices/XISessionServiceProxy.h>

@interface XITimeSeriesProxy : NSObject <XITimeSeries, XISessionServiceProxy>

@end

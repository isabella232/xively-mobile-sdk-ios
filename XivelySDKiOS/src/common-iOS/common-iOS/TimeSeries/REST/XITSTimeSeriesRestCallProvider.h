//
//  XITSTimeSeriesRestCallProvider.h
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XITSTimeSeriesCallProvider.h"
#import <Internals/SessionServices/XISessionServicesCallProvider.h>

@interface XITSTimeSeriesRestCallProvider : NSObject <XITSTimeSeriesCallProvider, XISessionServicesCallProvider>

@end

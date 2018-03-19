//
//  XITSTimeSeriesRestCall.h
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XITSTimeSeriesCall.h"

@interface XITSTimeSeriesRestCall : NSObject <XITSTimeSeriesCall, XIRESTCallDelegate>

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig;


@end

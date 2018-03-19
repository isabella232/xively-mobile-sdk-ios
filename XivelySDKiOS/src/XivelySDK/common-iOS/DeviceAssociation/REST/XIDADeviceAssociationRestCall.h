//
//  XIDADeviceAssociationRestCall.h
//  common-iOS
//
//  Created by vfabian on 17/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIDADeviceAssociationCall.h"

@interface XIDADeviceAssociationRestCall : NSObject <XIDADeviceAssociationCall, XIRESTCallDelegate>

- (instancetype)initWithLogger:(id<XICOLogging>)logger
              restCallProvider:(id<XIRESTCallProvider>)provider
                servicesConfig:(XIServicesConfig *)servicesConfig;
    
@end

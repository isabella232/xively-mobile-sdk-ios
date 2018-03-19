//
//  XIDADeviceAssociationRestCallProvider.h
//  common-iOS
//
//  Created by vfabian on 17/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIDADeviceAssociationCallProvider.h"
#import <Internals/SessionServices/XISessionServicesCallProvider.h>

@interface XIDADeviceAssociationRestCallProvider : NSObject <XIDADeviceAssociationCallProvider, XISessionServicesCallProvider>

@end

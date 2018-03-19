//
//  XIDADeviceAssociation.h
//  common-iOS
//
//  Created by vfabian on 16/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/DeviceAssociation/XIDeviceAssociation.h>
#import "XIDADeviceAssociationCallProvider.h"
#import <Internals/Session/XICOSessionNotifications.h>
#import <Internals/SessionServices/XISessionServiceWithCallProvider.h>

@interface XIDADeviceAssociation : NSObject <XIDeviceAssociation, XISessionServiceWithCallProvider>

@end

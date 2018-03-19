//
//  XIDeviceAssociationProxy.h
//  common-iOS
//
//  Created by vfabian on 16/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/DeviceAssociation/XIDeviceAssociation.h>
#import <Internals/SessionServices/XISessionServiceProxy.h>

@interface XIDeviceAssociationProxy : NSObject<XIDeviceAssociation, XISessionServiceProxy>

@end

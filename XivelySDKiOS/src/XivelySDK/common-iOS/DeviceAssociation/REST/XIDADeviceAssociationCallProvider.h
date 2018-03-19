//
//  XIDADeviceAssociationCallProvider.h
//  common-iOS
//
//  Created by vfabian on 17/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIDADeviceAssociationCall.h"

@protocol XIDADeviceAssociationCallProvider <NSObject>

- (id<XIDADeviceAssociationCall>)deviceAssociationCall;

@end

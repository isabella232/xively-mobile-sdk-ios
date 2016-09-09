//
//  XISessionServiceWithCallProvider.h
//  common-iOS
//
//  Created by vfabian on 05/10/15.
//  Copyright © 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XISessionServiceWithCallProvider <NSObject>

@property(weak, nonatomic)id proxy;

- (id)initWithLogger:(id<XICOLogging>)logger
        callProvider:(id)callProvider
               proxy:(id)proxy
              access:(XIAccess *)access
       notifications:(XICOSessionNotifications *)notifications
              config:(XIServicesConfig *)serviceConfig;

@end

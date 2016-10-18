//
//  XivelyHelloWord.h
//  TutorialObjC
//
//  Copyright © 2015 Xively. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <XivelySDK/XivelySDK.h>
#import "DeviceInfoList.h"

@interface XivelyService : NSObject <XIAuthenticationDelegate,
                                   XIMessagingCreatorDelegate,
                                     XIDeviceInfoListDelegate,
                                XIOrganizationHandlerDelegate>

@property(nonatomic, strong)NSString *accountId;
@property(nonatomic, strong)NSString *username;
@property(nonatomic, strong)NSString *password;
@property(nonatomic, strong)NSString *messagingChannel;

@property(nonatomic, strong)XIAuthentication *authentication;
@property(nonatomic, strong)id<XISession> session;
@property(nonatomic, strong)id<XIMessagingCreator> messagingCreator;
@property(nonatomic, strong)id<XIMessaging> messaging;
@property(nonatomic, strong)id<XIOrganizationHandler> organizationHandler;

@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, strong)UIViewController* loginController;
@property(nonatomic, strong)DeviceInfoList* infoList;
@property(nonatomic, strong)NSArray* deviceInfos;
@property(nonatomic, strong)NSArray* organizationInfos;

//Call start to start the Xively Hello World
- (void)login : ( UIViewController* ) viewController;

//Call stop to finish periodically publishing messages and cleanup
- (void)stop;

- (id<XITimeSeries>)timeSeries;

+ (XivelyService*) sharedXivelyService;

@end

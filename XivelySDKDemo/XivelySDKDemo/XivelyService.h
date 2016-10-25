//
//  XivelyHelloWord.h
//  TutorialObjC
//
//  Copyright © 2015 Xively. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <XivelySDK/XivelySDK.h>

@class XivelyService;

@protocol XivelyServiceDelegate <NSObject>
- (void)xivelyService:(XivelyService*)xivelyService createdMessaging:(id<XIMessaging>)messaging;
- (void)xivelyService:(XivelyService*)xivelyService failedToCreateMessaging:(NSError*)error;
@end



@interface XivelyService : NSObject <XIMessagingCreatorDelegate,
                                       XIDeviceInfoListDelegate,
                                  XIOrganizationHandlerDelegate>

@property(nonatomic, strong)NSString *messagingChannel;

@property(nonatomic, strong)id<XISession> session;
@property(nonatomic, strong)id<XIMessagingCreator> messagingCreator;
@property(nonatomic, strong)id<XIOrganizationHandler> organizationHandler;

@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, strong)id<XIDeviceInfoList> infoList;
@property(nonatomic, strong)NSArray* deviceInfos;
@property(nonatomic, strong)NSArray* organizationInfos;

@property(nonatomic) bool connectCleanSession;
@property(nonatomic, strong) NSString* connectLastWillTopic;
@property(nonatomic, strong) NSString* connectLastWillMessage;
@property(nonatomic) NSUInteger connectLastWillQoS;
@property(nonatomic) bool connectLastWillRetain;

@property(nonatomic, weak)id<XivelyServiceDelegate> delegate;

- (void)createMessaging;

- (id<XITimeSeries>)timeSeries;

+ (XivelyService*) sharedXivelyService;

@end

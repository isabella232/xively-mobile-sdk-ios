//
//  XivelyHelloWord.h
//  TutorialObjC
//
//  Copyright © 2015 Xively. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XivelySDK/XivelySDK.h>

@interface XivelyHelloWorld : NSObject <XIAuthenticationDelegate,
                                        XIMessagingCreatorDelegate,
                                        XIMessagingSubscriptionListener,
                                        XIMessagingDataListener>

@property(nonatomic, strong)NSString *accountId;
@property(nonatomic, strong)NSString *username;
@property(nonatomic, strong)NSString *password;
@property(nonatomic, strong)NSString *messagingChannel;

@property(nonatomic, strong)XIAuthentication *authentication;
@property(nonatomic, strong)id<XISession> session;
@property(nonatomic, strong)id<XIMessagingCreator> messagingCreator;
@property(nonatomic, strong)id<XIMessaging> messaging;

@property(nonatomic, strong)NSTimer *timer;

//Call start to start the Xively Hello World
- (void)start;

//Call stop to finish periodically publishing messages and cleanup
- (void)stop;

@end

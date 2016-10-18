//
//  XivelyHelloWord.m
//  TutorialObjC
//
//  Copyright © 2015 Xively. All rights reserved.
//

#import "XivelyService.h"

XivelyService* staticService = nil;

@implementation XivelyService

+ (XivelyService*) sharedXivelyService
{
    if ( staticService == nil ) staticService = [[XivelyService alloc] init];
    return staticService;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

//Call start to start the Xively Hello World
- (void)login : ( UIViewController* ) viewController {
    //Create an authentication object and set to call its result back on this instance
    self.loginController = viewController;
    
    self.authentication = [[XIAuthentication alloc] initWithSdkConfig:[XISdkConfig config]];
    self.authentication.delegate = self;
    NSLog(@"Authentication object created and set");
    
    //Start authentication. It is an asynchronous request.
    //The result is called back on the methods defined in XIAuthenticationDelegate
    [self.authentication requestLoginWithUsername:self.username
                                         password:self.password
                                        accountId:self.accountId];
    NSLog(@"Authentication requested");
}

//Call stop to finish periodically publishing messages and cleanup
- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
    [self.messaging close];
    [self.messagingCreator cancel];
    [self.session close];
    self.session = nil;
}

#pragma XIAuthenticationDelegate
- (void)authentication:(XIAuthentication *)authentication didFailWithError:(NSError *)error {
    //The execution returns here if the authentication failed
    NSLog(@"Authentication failed");
}

- (void)authentication:(XIAuthentication *)authentication didCreateSession:(id<XISession>)session {
    //The execution returns here if the authentication was successful
    NSLog(@"Authentication success");
    
    //The preserve the session for later use. A session wraps in a jwt with some user data.
    //Services like messaging or Time Series can be created through this object.
    self.session = session;
    
    // Device info list
    self.infoList = [session.services deviceInfoList];
    self.infoList.delegate = self;
    [self.infoList requestList];
    
    [self.loginController performSegueWithIdentifier:@"loginSeque" sender:self];
    self.messagingCreator = [[session services] messagingCreator];
    [self.messagingCreator setMessagingCreatorDelegate:self];
    [self.messagingCreator createMessaging];
    
    // Origanization info list
    self.organizationHandler = [session.services organizationHandler];
    [self.organizationHandler setDelegate:self];
    [self.organizationHandler listOrganizations];
}

- (id<XITimeSeries>)timeSeries
{
    return [[self.session services] timeSeries];
}

- (void)deviceInfoList:(id<XIDeviceInfoList>)deviceInfoList didReceiveList:(NSArray *)deviceInfos
{
    NSLog(@"LIST RECEIVED %@" , deviceInfos);
    self.deviceInfos = deviceInfos;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"showDevices" object:nil];
}

- (void)deviceInfoList:(id<XIDeviceInfoList>)deviceInfoList didFailWithError:(NSError *)error
{
    NSLog(@"Failed fetch device list from the server: %@", [error localizedDescription]);
}

#pragma XIMessagingCreatorDelegate
- (void)messagingCreator:(id<XIMessagingCreator>)creator
        didFailToCreateMessagingWithError:(NSError *)error {
    //Building up a Messaging connection failed.
    self.messagingCreator = nil;
    NSLog(@"Messaging connection failed");
}

- (void)messagingCreator:(id<XIMessagingCreator>)creator
        didCreateMessaging:(id<XIMessaging>)messaging {
    //The Messaging successfully connected to the broker.
    //The received Messaging instance is up and running.
    self.messagingCreator = nil;
    NSLog(@"Messaging connected");
    
    //Preserve the messaging instance for later use
    self.messaging = messaging;
}

#pragma mark Organization handling
- (void)organizationHandler:(id<XIOrganizationHandler>)organizationhandler didReceiveList:(NSArray *)organizationInfos
{
    self.organizationInfos = organizationInfos;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"showOrganizations" object:nil];
}


@end

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
        self.connectCleanSession = true;
        self.connectLastWillTopic = @"";
        self.connectLastWillMessage = @"";
        self.connectLastWillQoS = 0;
        self.connectLastWillRetain = false;
    }
    return self;
}

#pragma XIAuthenticationDelegate

- (void)setSession:(id<XISession>)session {
    if (_session != session) {
        _session = session;
    }
    //The execution returns here if the authentication was successful
    NSLog(@"Authentication success");
    
    // Device info list
    self.infoList = [session.services deviceInfoList];
    self.infoList.delegate = self;
    [self.infoList requestList];
    
    // Origanization info list
    self.organizationHandler = [session.services organizationHandler];
    [self.organizationHandler setDelegate:self];
    [self.organizationHandler listOrganizations];
}

- (void)createMessaging {
    NSLog(@"Create messaging...");
    self.messagingCreator = [[self.session services] messagingCreator];
    [self.messagingCreator setMessagingCreatorDelegate:self];
    
    if ([self.connectLastWillTopic isEqualToString:@""]) {
        [self.messagingCreator createMessagingWithCleanSession:self.connectCleanSession];
    } else {
        NSData* messageData = [self.connectLastWillMessage dataUsingEncoding:NSUTF8StringEncoding];
        XILastWill* lastWill = [[XILastWill alloc] initWithChannel:self.connectLastWillTopic
                                                           message:messageData
                                                               qos:((self.connectLastWillQoS == 0) ? XIMessagingQoSAtMostOnce : XIMessagingQoSAtLeastOnce)
                                                            retain:self.connectLastWillRetain];
        [self.messagingCreator createMessagingWithCleanSession:self.connectCleanSession lastWill:lastWill];
    }
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
    if (self.delegate) {
        [self.delegate xivelyService:self failedToCreateMessaging:error];
    }
}

- (void)messagingCreator:(id<XIMessagingCreator>)creator
        didCreateMessaging:(id<XIMessaging>)messaging {
    //The Messaging successfully connected to the broker.
    //The received Messaging instance is up and running.
    self.messagingCreator = nil;
    NSLog(@"Messaging connected");
    //Preserve the messaging instance for later use
    if (self.delegate) {
        [self.delegate xivelyService:self createdMessaging:messaging];
    }
}

#pragma mark Organization handling
- (void)organizationHandler:(id<XIOrganizationHandler>)organizationhandler didReceiveList:(NSArray *)organizationInfos
{
    self.organizationInfos = organizationInfos;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"showOrganizations" object:nil];
}

- (void)organizationHandler:(id<XIOrganizationHandler>)organizationHandler didReceiveOrganizationInfo:(XIOrganizationInfo *)organizationInfo
{
    
}

- (void)organizationHandler:(id<XIOrganizationHandler>)organizationHandler didFailWithError:(NSError *)error;
{
    NSLog(@"Got an error while receiving organization infos: %@", [error localizedDescription]);
}

@end

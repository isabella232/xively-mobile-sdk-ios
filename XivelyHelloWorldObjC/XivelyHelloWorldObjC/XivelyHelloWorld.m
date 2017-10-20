//
//  XivelyHelloWord.m
//  TutorialObjC
//
//  Copyright © 2015 Xively. All rights reserved.
//

#import "XivelyHelloWorld.h"

@implementation XivelyHelloWorld

- (instancetype)init {
    self = [super init];
    if (self) {
         ///////////////////////////////////////////////
        //////////////XIVELY CONFIGURATION/////////////
        self.accountId = @"***REMOVED***";
        self.username = @"***REMOVED***";
        self.password = @"***REMOVED***";
        self.messagingChannel = @"xi/blue/v1/***REMOVED***/d/bb80e745-c1e3-443d-bde1-7f82fe356c0a/_log";
         ///////////////////////////////////////////////
        ///////////////////////////////////////////////
    }
    return self;
}

//Call start to start the Xively Hello World
- (void)start {
    //Create an authentication object and set to call its result back on this instance
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
    
    //The Messaging Creator builds up a Messaging connection. It is also asynchronous, therefore
    //its result is called back on the methods defined in XIMessagingCreatorDelegate
    self.messagingCreator = [session.services messagingCreator];
    self.messagingCreator.delegate = self;
    [self.messagingCreator createMessaging];
    NSLog(@"Messaging connecting");
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
    
    //Enable this object to receive if the following subscription succeeds or not
    [messaging addSubscriptionListener:self];
    
    //Subscribe to a predefined topic. It is also an asynchronous call.
    //Its result needs to be checked on the methods defined in XIMessagingSubscriptionListener
    [self.messaging subscribeToChannel:self.messagingChannel qos:XIMessagingQoSAtMostOnce];
    NSLog(@"Subscribing to Messaging Channel");
}

#pragma XIMessagingSubscriptionListener
- (void)messaging:(id<XIMessaging>)messaging
        didFailToSubscribeToChannel:(NSString *)channel error:(NSError *)error {
    //Subscription failed
    NSLog(@"Subscription error");
}

- (void)messaging:(id<XIMessaging>)messaging
        didSubscribeToChannel:(NSString *)channel qos:(XIMessagingQoS)qos {
    //Subscription was successfull
    NSLog(@"Subscription success");
    
    //Enable this object to be notified on message arrivals on the subscribed channels.
    //The messages arrive on the methods defined in XIMessagingDataListener
    [self.messaging addDataListener:self];
    
    //Publish once
    [self timerTick];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                selector:@selector(timerTick) userInfo:nil repeats:YES];
}

- (void)messaging:(id<XIMessaging>)messaging
    didFailToUnsubscribeFromChannel:(NSString *)channel error:(NSError *)error {}

- (void)messaging:(id<XIMessaging>)messaging
    didUnsubscribeFromChannel:(NSString *)channel {}

#pragma Timer ticks
- (void)timerTick {
    //The timer trigger this method
    NSString *testMessage = @"Hello World";
    
    //Publish "Hello World" string to the predefined topic
    [self.messaging publishToChannel:self.messagingChannel
                             message:[testMessage dataUsingEncoding:NSUTF8StringEncoding]
                                 qos:XIMessagingQoSAtMostOnce];
    NSLog(@"Test message published to Messaging Channel");
}

#pragma XIMessagingDataListener
- (void)messaging:(id<XIMessaging>)messaging
        didReceiveData:(NSData *)message onChannel:(NSString *)channel {
    //A message was received on a subscribed channel
    if ([channel isEqualToString:self.messagingChannel]) {
        NSString *receivedMessage = [[NSString alloc] initWithData:message
                                                          encoding:NSUTF8StringEncoding];
        NSLog(@"Message received: '%@'", receivedMessage);
    }
}

@end

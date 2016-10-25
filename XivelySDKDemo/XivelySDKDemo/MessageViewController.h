//
//  MessageViewController.h
//  XivelySDKDemo
//
//  Created by Tamas Korodi on 2016. 10. 07..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XivelySDK/XivelySDK.h>
#import "XivelyService.h"

@interface MessageViewController : UIViewController <XIMessagingStateListener, XIMessagingDataListener, XIMessagingSubscriptionListener
                                                     , XITimeSeriesDelegate,  XivelyServiceDelegate>

@property (strong, nonatomic) XIDeviceChannel* channel;
@property (strong, nonatomic) id<XITimeSeries> timeSeries;

@property (weak, nonatomic) IBOutlet UITextField *messageInputTextField;
@property (weak, nonatomic) IBOutlet UITextView *incomingMessagesTextView;

@property (strong, nonatomic) id<XIMessaging> messaging;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qosSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *retainSwitch;

- (IBAction)sendPushed:(id)sender;

@end

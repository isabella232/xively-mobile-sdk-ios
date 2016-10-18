//
//  MessageViewController.h
//  XivelySDKDemo
//
//  Created by Tamas Korodi on 2016. 10. 07..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XivelySDK/XivelySDK.h>

@interface MessageViewController : UIViewController <XIMessagingStateListener, XIMessagingDataListener, XIMessagingSubscriptionListener
                                                     , XITimeSeriesDelegate>

@property (strong, nonatomic) XIDeviceChannel* channel;
@property (strong, nonatomic) id<XITimeSeries> timeSeries;

@property (weak, nonatomic) IBOutlet UITextField *messageInputTextField;
@property (weak, nonatomic) IBOutlet UITextView *incomingMessagesTextView;
- (IBAction)sendPushed:(id)sender;

@end

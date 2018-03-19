//
//  DetailViewController.h
//  XivelySDKDemo
//
//  Created by Milan Toth on 2016. 09. 27..
//  Copyright © 2016. Xively. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XivelySDK/XivelySDK.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) XIDeviceInfo *detailItem;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIButton *channelsButton;


@end


//
//  SettingsController.h
//  XivelySDKDemo
//
//  Created by Tamas Korodi on 2016. 10. 19..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *cleanSessionSwitch;
@property (weak, nonatomic) IBOutlet UITextField *lastWillTopicNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastWillMessageTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lastWillQoSSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *lastWillRetainSwitch;

@end

//
//  SettingsController.m
//  XivelySDKDemo
//
//  Created by Tamas Korodi on 2016. 10. 19..
//  Copyright © 2016. Xively. All rights reserved.
//

#import "SettingsController.h"
#import "XivelyService.h"

@interface SettingsController ()

@end

@implementation SettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    XivelyService* srv = [XivelyService sharedXivelyService];
    [self.cleanSessionSwitch setOn:srv.connectCleanSession];
    [self.lastWillTopicNameTextField setText:srv.connectLastWillTopic];
    [self.lastWillMessageTextField setText:srv.connectLastWillMessage];
    [self.lastWillQoSSegmentedControl setSelectedSegmentIndex:srv.connectLastWillQoS];
    [self.lastWillRetainSwitch setOn:srv.connectLastWillRetain];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    XivelyService* srv = [XivelyService sharedXivelyService];
    srv.connectCleanSession = self.cleanSessionSwitch.on;
    srv.connectLastWillTopic = self.lastWillTopicNameTextField.text;
    srv.connectLastWillMessage = self.lastWillMessageTextField.text;
    srv.connectLastWillQoS = self.lastWillQoSSegmentedControl.selectedSegmentIndex;
    srv.connectLastWillRetain = self.lastWillRetainSwitch.on;
    [super viewWillDisappear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

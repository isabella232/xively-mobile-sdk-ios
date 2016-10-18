//
//  LoginViewController.m
//  XivelySDKDemo
//
//  Created by Milan Toth on 2016. 09. 27..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginPressed:(id)sender {
    [[XivelyService sharedXivelyService] setAccountId:self.accountId.text];
    [[XivelyService sharedXivelyService] setUsername:self.userName.text];
    [[XivelyService sharedXivelyService] setPassword:self.password.text];
    [[XivelyService sharedXivelyService] login: self];
    
    [self.loginButton setEnabled:false];
    [self.activityIndicator startAnimating];
}

@end

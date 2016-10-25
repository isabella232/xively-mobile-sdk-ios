//
//  LoginViewController.h
//  XivelySDKDemo
//
//  Created by Milan Toth on 2016. 09. 27..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XivelyService.h"
#import <XivelySDK/XivelySDK.h>

@interface LoginViewController : UIViewController <XIAuthenticationDelegate>

@property (strong, nonatomic) XIAuthentication* authentication;

@property (weak, nonatomic) IBOutlet UITextField *accountId;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *errorTextField;

- (IBAction)loginPressed:(id)sender;
@end

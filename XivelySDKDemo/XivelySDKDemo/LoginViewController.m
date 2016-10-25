//
//  LoginViewController.m
//  XivelySDKDemo
//
//  Created by Milan Toth on 2016. 09. 27..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"

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
    [self.loginButton setEnabled:false];
    [self.activityIndicator startAnimating];
    self.errorTextField.text = @"";
    
    self.authentication = [[XIAuthentication alloc] initWithSdkConfig:[XISdkConfig config]];
    self.authentication.delegate = self;
    NSLog(@"Authentication object created and set");
    
    //Start authentication. It is an asynchronous request.
    //The result is called back on the methods defined in XIAuthenticationDelegate
    [self.authentication requestLoginWithUsername:self.userName.text
                                         password:self.password.text
                                        accountId:self.accountId.text];

    NSLog(@"Authentication requested");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"loginSeque"]) {
        MasterViewController *controller = (MasterViewController *)[segue destinationViewController];
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        controller.parentName = @"Logout";
    }
}

#pragma mark auth handling
/**
 * @brief The authentication did end with an error.
 * @param authentication The authentication instance that initiates the callback.
 * @param error The reason of the error. The possible reasons are defined in \link XICommonError.h \endlink and \link XIAuthenticationError.h \endlink.
 * @since Version 1.0
 */
- (void)authentication:(XIAuthentication *)authentication didFailWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    [self.loginButton setEnabled:YES];
    self.errorTextField.text = [error localizedDescription];
}

/**
 * @brief The request is finished successfully, and returns a valid \link XISession XISession \endlink object.
 * @param authentication The authentication instance that initiates the callback.
 * @param session The session that is created by the authentication.
 * @since Version 1.0
 */
- (void)authentication:(XIAuthentication *)authentication didCreateSession:(id<XISession>)session
{
    [self.activityIndicator stopAnimating];
    [self.loginButton setEnabled:YES];
    [[XivelyService sharedXivelyService] setSession: session];
    [self performSegueWithIdentifier:@"loginSeque" sender:self];
}


@end

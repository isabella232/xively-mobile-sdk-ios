//
//  DetailViewController.m
//  XivelySDKDemo
//
//  Created by Milan Toth on 2016. 09. 27..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import "DetailViewController.h"
#import "ChannelViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        XIDeviceInfo* info = self.detailItem;
        self.detailTextView.text = [NSString stringWithFormat: @"Name: %@\nId: %@\nLocation: %@\nSerial number: %@\nDevice version: %@\nPurchase date: %@\nProvisioning state: %i " ,
            info.deviceName ,
            info.deviceId ,
            info.deviceLocation ,
            info.serialNumber ,
            info.deviceVersion ,
            info.purchaseDate ,
            (int)info.provisioningState ];
        
        [self.channelsButton setTitle: [NSString stringWithFormat:@"Channels (%lu)", (unsigned long)[info.deviceChannels count]]
                             forState:UIControlStateNormal];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showChannels"]) {
        ChannelViewController *controller = (ChannelViewController *)[segue destinationViewController];
        if (self.detailItem) {
            XIDeviceInfo* info = (XIDeviceInfo*)self.detailItem;
            [controller setChannels:info.deviceChannels];
        }
    }
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(XIDeviceInfo *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}


@end

//
//  ChannelViewController.m
//  XivelySDKDemo
//
//  Created by Tamas Korodi on 2016. 10. 05..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import "ChannelViewController.h"
#import "MessageViewController.h"
#import <XivelySDK/XivelySDK.h>

@interface ChannelViewController ()

@end

@implementation ChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.channels count];
}

- (NSString*)shortTopic:(NSString*)topic {
    return [[topic componentsSeparatedByString:@"/"] lastObject];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelId" forIndexPath:indexPath];
    
    XIDeviceChannel* channel = self.channels[indexPath.row];
    cell.textLabel.text = [self shortTopic:channel.channelId];
    cell.detailTextLabel.text = channel.persistenceType == XIDeviceChannelPersistanceTypeSimple ? @"General" : @"Timeseries";
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMessages"]) {
        MessageViewController *controller = (MessageViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        XIDeviceChannel* channel = self.channels[indexPath.row];
        [controller setChannel:channel];
        [controller setTitle:[self shortTopic:channel.channelId]];
    }
}

@end

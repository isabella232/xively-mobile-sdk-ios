//
//  MasterViewController.m
//  XivelySDKDemo
//
//  Created by Milan Toth on 2016. 09. 27..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)filterOrganizations {
    NSMutableArray* organizations = NSMutableArray.new;
    for (XIOrganizationInfo* org in [[XivelyService sharedXivelyService] organizationInfos]) {
        if ((org.parentId == nil && self.parentOrganizationId == nil) || [org.parentId isEqualToString:self.parentOrganizationId]) {
            [organizations addObject: org];
        }
    }
    self.organizations = organizations;
}

- (void)filterDevices {
    NSMutableArray* devices = NSMutableArray.new;
    for (XIDeviceInfo* dev in [[XivelyService sharedXivelyService] deviceInfos]) {
        if ([dev.organizationId isEqualToString:self.parentOrganizationId]) {
            [devices addObject: dev];
        }
    }
    self.devices = devices;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"showDevices" object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         [self filterDevices];
         [[self tableView] reloadData];
     }];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"showOrganizations" object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         [self filterOrganizations];
         [[self tableView] reloadData];
     }];
    
    [self filterDevices];
    [self filterOrganizations];
    [[self tableView] reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                                         initWithTitle:self.parentName style:UIBarButtonItemStylePlain target:nil action:nil];
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        XIDeviceInfo *dev = self.devices[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[segue destinationViewController];
        [controller setDetailItem:dev];
        [controller setTitle:dev.deviceName];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    } else if ([[segue identifier] isEqualToString:@"showGroup"]) {
        MasterViewController* nextController = (MasterViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        XIOrganizationInfo *org = self.organizations[indexPath.row];
        [nextController setTitle:org.name];
        nextController.parentOrganizationId = org.organizationId;
        nextController.parentName = self.title;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return [NSString stringWithFormat:@"Organizations (%ld)", [self.organizations count]];
    }
    else if(section == 1)
    {
        return [NSString stringWithFormat:@"Devices (%ld)", [self.devices count]];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ( self.organizations == nil ) return 0;
        else return [ self.organizations count ];
    } else if (section == 1) {
        if ( self.devices == nil ) return 0;
        else return [ self.devices count ];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 0 ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"organization" forIndexPath:indexPath];
        NSArray* infos = self.organizations;
        XIOrganizationInfo* info = infos[ indexPath.row ];
        cell.textLabel.text = [ info name ];
        cell.detailTextLabel.text = [ info organizationId ];
        return cell;
    } else if ( indexPath.section == 1 ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"device" forIndexPath:indexPath];
        NSArray* infos = self.devices;
        XIDeviceInfo* info = infos[ indexPath.row ];
        cell.textLabel.text = [ info deviceName ];
        cell.detailTextLabel.text = [ info deviceId ];
        return cell;
    } else {
        return nil;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
}


@end

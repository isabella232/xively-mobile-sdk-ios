//
//  MasterViewController.h
//  XivelySDKDemo
//
//  Created by Milan Toth on 2016. 09. 27..
//  Copyright © 2016. LogMeIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XivelyService.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSString* parentOrganizationId;
@property (strong, nonatomic) NSString* parentName;
@property (strong, nonatomic) NSArray* organizations;
@property (strong, nonatomic) NSArray* devices;

@end


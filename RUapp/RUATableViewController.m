//
//  RUATableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUATableViewController.h"

#import "RUAColor.h"

@interface RUATableViewController ()

@end

@implementation RUATableViewController

#pragma mark - UITableViewController methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    // Set appearance to header text label.
    view.textLabel.backgroundColor = [RUAColor darkBlueColor];
    view.textLabel.opaque = YES;
    view.textLabel.textColor = [RUAColor lightGrayColor];
    view.textLabel.shadowColor = nil;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    // Basic preparation.
    [super viewDidLoad];
    
    // Set global appearance.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.tableView.backgroundView = nil;
    
    // Set appearance by iOS version.
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6 and earlier.
        self.navigationController.navigationBar.translucent = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

@end

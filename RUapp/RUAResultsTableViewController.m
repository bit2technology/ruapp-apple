//
//  RUAResultsTableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 2014-06-01.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAResultsTableViewController.h"

#import "RUAColor.h"

@interface RUAResultsTableViewController ()

@end

@implementation RUAResultsTableViewController

#pragma mark - UITableViewController methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    // Set appearance to header text label.
    view.textLabel.textColor = [RUAColor lightGrayColor];
    view.textLabel.shadowColor = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set appearance to cells.
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [RUAColor darkerBlueColor];
    cell.textLabel.textColor = [RUAColor whiteColor];
    return cell;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    // Basic preparation.
    [super viewDidLoad];
    
    // Set global appearance.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.tableView.backgroundColor = [RUAColor darkBlueColor];
    self.tableView.backgroundView = nil;
    self.tableView.separatorColor = [RUAColor darkGrayColor];
    
    // Set appearance by iOS version.
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7 and later.
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconVoteSelected"];
    } else {
        // iOS 6 and earlier.
        self.navigationController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconVoteOld"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

@end

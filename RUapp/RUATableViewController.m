//
//  RUATableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUATableViewController.h"
#import "RUAColor.h"

@implementation RUATableViewLoadingCell

@end

@implementation RUATableViewController

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    // Reload table view with new font.
    [self.tableView reloadData];
}

#pragma mark - UITableViewController methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    // Set appearance to header text label.
    view.textLabel.backgroundColor = [RUAColor darkBlueColor];
    view.textLabel.opaque = YES;
    view.textLabel.textColor = [RUAColor lightGrayColor];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    // Observe font size changes.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

#pragma mark - NSObject methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

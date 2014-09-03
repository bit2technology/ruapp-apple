//
//  RUATableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAColor.h"
#import "RUATableViewController.h"

@implementation RUATableViewController

// MARK: Methods

- (UIView *)tableViewBackgroundViewWithMessage:(NSString *)message
{
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    messageLabel.backgroundColor = [RUAColor darkBlueColor];
    messageLabel.numberOfLines = NSIntegerMax;
    messageLabel.opaque = YES;
    messageLabel.text = message;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = [UIColor lightGrayColor];
    return messageLabel;
}

- (UIView *)tableViewHeaderViewPullToRefresh
{
    return [self tableViewBackgroundViewWithMessage:NSLocalizedString(@"Pull down to refresh", @"Message to show on top of empity views, suggesting how to refresh")];
}

// MARK: Helper methods

/**
 * Method called to configure header and footer views of table view.
 */
- (void)configureHeaderFooterView:(UITableViewHeaderFooterView *)view
{
    // Set appearance to text label.
    view.textLabel.backgroundColor = [RUAColor darkBlueColor];
    view.textLabel.opaque = YES;
    view.textLabel.textColor = [RUAColor lightGrayColor];
}

/**
 * Method called when dynamic type font size changes.
 */
- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    // Reload table view with new font.
    [self.tableView reloadData];
}

// MARK: UITableViewController

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    [self configureHeaderFooterView:view];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    [self configureHeaderFooterView:view];
}

// MARK: UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Observe font size changes.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

// MARK: NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

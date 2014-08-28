//
//  RUATableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUATableViewController.h"
#import "RUAColor.h"

@implementation RUATableViewController

- (UIView *)tableViewBackgroundViewWithMessage:(NSString *)message
{
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGFLOAT_MAX, 44)];
    messageLabel.backgroundColor = [RUAColor darkBlueColor];
    messageLabel.numberOfLines = NSIntegerMax;
    messageLabel.opaque = YES;
    messageLabel.text = message;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = [UIColor lightGrayColor];
    return messageLabel;
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    // Reload table view with new font.
    [self.tableView reloadData];
}

- (void)configureHeaderFooterView:(UITableViewHeaderFooterView *)view
{
    // Set appearance to text label.
    view.textLabel.backgroundColor = [RUAColor darkBlueColor];
    view.textLabel.opaque = YES;
    view.textLabel.textColor = [RUAColor lightGrayColor];
}

// MARK: UITableViewController methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    [self configureHeaderFooterView:view];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    [self configureHeaderFooterView:view];
}

// MARK: UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Observe font size changes.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

// MARK: NSObject methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

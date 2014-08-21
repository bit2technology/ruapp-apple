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
    UILabel *backgroundView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    backgroundView.text = message;
    backgroundView.textAlignment = NSTextAlignmentCenter;
    backgroundView.textColor = [UIColor lightGrayColor];
    backgroundView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    backgroundView.numberOfLines = NSIntegerMax;
    return backgroundView;
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    // Reload table view with new font.
    [self.tableView reloadData];
}

// MARK: UITableViewController methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    // Set appearance to header text label.
    view.textLabel.backgroundColor = [RUAColor darkBlueColor];
    view.textLabel.opaque = YES;
    view.textLabel.textColor = [RUAColor lightGrayColor];
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

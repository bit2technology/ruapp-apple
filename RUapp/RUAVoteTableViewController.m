//
//  RUAVoteTableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 30/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAVoteTableViewController.h"

#import "RUAColor.h"

@interface RUAVoteTableViewController ()

@property (strong, nonatomic) NSMutableArray *checkedIndexPaths;

@end

@implementation RUAVoteTableViewController

- (IBAction)submitVote:(id)sender
{
    // TODO: Alert view delegate.
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to submit this vote?", @"Vote alert view title")
                               message:nil
                              delegate:nil
                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"Vote alert view cancel button")
                     otherButtonTitles:NSLocalizedString(@"Submit", @"Vote alert view submit button"), nil] show];
}

#pragma mark - UITableViewController methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    // Set appearance to header text label.
    view.textLabel.textColor = [RUAColor lightGrayColor];
    view.textLabel.shadowColor = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Rows don't stay selected, only checked.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get already checked row in this section, if any.
    __block NSIndexPath *oldCheckedIndexPath = nil;
    [self.checkedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *idxPth, NSUInteger idx, BOOL *stop) {
        if (idxPth.section == indexPath.section) {
            oldCheckedIndexPath = idxPth;
            *stop = YES;
        }
    }];
    
    // Uncheck old row, remove it from contro array, check new one and add it to the array.
    [tableView cellForRowAtIndexPath:oldCheckedIndexPath].accessoryType = UITableViewCellAccessoryNone;
    [self.checkedIndexPaths removeObject:oldCheckedIndexPath];
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.checkedIndexPaths addObject:indexPath];
    
    // Verify obligatory fields.
    __block NSInteger obligatoryFields = 0;
    [self.checkedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *idxPth, NSUInteger idx, BOOL *stop) {
        if ((idxPth.section >= 0) && (idxPth.section <= 1)) {
            obligatoryFields++;
        }
    }];
    
    // If the vote is filled, enable submit button.
    self.navigationItem.rightBarButtonItem.enabled = (obligatoryFields >= 2);
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    // Basic preparation.
    [super viewDidLoad];
    self.checkedIndexPaths = [NSMutableArray arrayWithCapacity:3];
    
    // Set global appearance.
    self.tableView.backgroundView = nil;
    
    // Set appearance by iOS version.
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7 and later.
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconVoteSelected"];
    } else {
        // iOS 6 and earlier.
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.translucent = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

@end

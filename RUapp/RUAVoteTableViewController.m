//
//  RUAVoteTableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 30/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAVoteTableViewController.h"
#import "RUAServerConnection.h"

@interface RUAVoteTableViewController () <UIAlertViewDelegate>

@property (assign, nonatomic) RUARating voteRating;
@property (assign, nonatomic) RUARestaurant voteLocal;

@end

@implementation RUAVoteTableViewController

- (IBAction)submitVote:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to submit this vote?", @"Vote alert view title")
                                message:NSLocalizedString(@"The vote can't be changed after you send it.", @"Vote alert view message")
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Vote alert view cancel button")
                      otherButtonTitles:NSLocalizedString(@"Submit", @"Vote alert view submit button"), nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If clicked OK.
    if (buttonIndex > 0) {
        
    }
}

#pragma mark - UITableViewController methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Rows don't stay selected, only checked.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Behavior by section.
    switch (indexPath.section) {
        case 0: // Rating.
            self.voteRating = (RUARating)indexPath.row;
            break;
        case 1: // Local.
            self.voteLocal = (RUARestaurant)indexPath.row;
            break;
            
        default:
            break;
    }
    
//    // Get already checked row in this section, if any.
//    __block NSIndexPath *oldCheckedIndexPath = nil;
//    [self.checkedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *idxPth, NSUInteger idx, BOOL *stop) {
//        if (idxPth.section == indexPath.section) {
//            oldCheckedIndexPath = idxPth;
//            *stop = YES;
//        }
//    }];
//    
//    // Uncheck old row, remove it from contro array, check new one and add it to the array.
//    [tableView cellForRowAtIndexPath:oldCheckedIndexPath].accessoryType = UITableViewCellAccessoryNone;
//    [self.checkedIndexPaths removeObject:oldCheckedIndexPath];
//    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
//    [self.checkedIndexPaths addObject:indexPath];
//    
//    // Verify obligatory fields.
//    __block NSInteger obligatoryFields = 0;
//    [self.checkedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *idxPth, NSUInteger idx, BOOL *stop) {
//        if ((idxPth.section >= 0) && (idxPth.section <= 1)) {
//            obligatoryFields++;
//        }
//    }];
//    
//    // If the vote is filled, enable submit button.
//    self.navigationItem.rightBarButtonItem.enabled = (obligatoryFields >= 2);
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    // Basic preparation.
    [super viewDidLoad];
    self.voteRating = NSNotFound;
    self.voteLocal = NSNotFound;
    
    // Set tab bar item's selected image.
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7 and later.
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconVoteSelected"];
    }
}

@end

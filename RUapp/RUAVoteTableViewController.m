//
//  RUAVoteTableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 30/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAVoteTableViewController.h"
#import "RUAServerConnection.h"
#import "RUAAppDelegate.h"
#import "RUAColor.h"

@interface RUAVoteTableViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSMutableArray *checkedIndexPaths;

@property (strong, nonatomic) NSDate *lastVoteDate;

@end

@implementation RUAVoteTableViewController

- (void)adjustInterfaceForVoteStatus
{
//    // If it is not time to vote, show appropriate interface.
//    if ([RUAAppDelegate mealForNow] == RUAMealNone) {
//        self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:NSLocalizedString(@"Sorry, there is no vote open now.", @"Vote not Disponible Message")];
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//        self.dataSource = nil;
//        [self.checkedIndexPaths removeAllObjects];
//    } else
    // If there is a vote, and it has less than 5 hours and the meal is the same, then show "already voted" interface.
    if (self.lastVoteDate && [self.lastVoteDate timeIntervalSinceNow] > -18000 && [RUAAppDelegate mealForDate:self.lastVoteDate] == [RUAAppDelegate mealForNow]) {
        self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:NSLocalizedString(@"Thank you! Vote computed.", @"Vote Computed Message")];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.dataSource = nil;
        [self.checkedIndexPaths removeAllObjects];
    } else
    // Set only if vote is allowed and dataSource is not set.
    if (!self.dataSource) {
        self.dataSource = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VoteDataSource" ofType:@"plist"]];
        self.tableView.backgroundView = nil;
    }
    [self.tableView reloadData];
}

- (IBAction)submitVote:(id)sender
{
    // Present confirmation alert.
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to submit this vote?", @"Vote alert view title")
                                message:NSLocalizedString(@"The vote can't be changed after you send it.", @"Vote alert view message")
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Vote alert view cancel button")
                      otherButtonTitles:NSLocalizedString(@"Submit", @"Vote alert view submit button"), nil] show];
}

// MARK: UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If clicked OK in confirmation alert.
    if (buttonIndex > 0) {
        // Update table view to show network activity.
        [self.tableView beginUpdates];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView startAnimating];
        self.tableView.backgroundView = activityView;
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.dataSource.count)] withRowAnimation:UITableViewRowAnimationTop];
        self.dataSource = nil;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.tableView endUpdates];
        
        // Colect vote info.
        RUARating rating = NSNotFound;
        RUARestaurant restaurant = RUARestaurantNone;
        NSMutableArray *dishes = [NSMutableArray array];
        for (NSIndexPath *checkedIndexPath in self.checkedIndexPaths) {
            switch (checkedIndexPath.section) {
                case 0: {
                    rating = (RUARating)checkedIndexPath.row;
                } break;
                case 1: {
                    restaurant = (RUARestaurant)checkedIndexPath.row;
                } break;
                case 2: {
                    [dishes addObject:[NSNumber numberWithUnsignedInteger:(RUADish)checkedIndexPath.row]];
                } break;
                    
                default:
                    break;
            }
        }
        
        // Send vote request.
        [RUAServerConnection sendVoteWithRestaurant:restaurant vote:rating reason:dishes completionHandler:^(NSDate *voteDate, NSError *error) {
            NSString *finishMessage;
            if (error) {
                NSLog(@"Vote error: %@", error.localizedDescription);
                finishMessage = NSLocalizedString(@"Ooops, we couldn't connect. Your vote will be sent as soon as possible.", @"Vote Computed Message");
            } else {
                finishMessage = NSLocalizedString(@"Thank you! Vote computed.", @"Vote Computed Message");
            }
            
            self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:finishMessage];
            
            self.lastVoteDate = voteDate;
            [[NSUserDefaults standardUserDefaults] setValue:voteDate forKey:@"lastVoteDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
}

#pragma mark - UITableViewController methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (NSInteger)self.dataSource.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.dataSource[(NSUInteger)section][@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[(NSArray *)self.dataSource[(NSUInteger)section][@"rows"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Vote Cell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSDictionary *rowInfo = self.dataSource[(NSUInteger)indexPath.section][@"rows"][(NSUInteger)indexPath.row];
    cell.textLabel.text = rowInfo[@"text"];
    NSString *imageName = rowInfo[@"image"];
    cell.imageView.image = (imageName ? [UIImage imageNamed:imageName] : nil);
    
    cell.accessoryType = ([self.checkedIndexPaths containsObject:indexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Rows don't stay selected, only checked.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Behavior by section.
    switch (indexPath.section) {
        case 0: // Meal avaliation and local.
        case 1: {
            // Get already checked row in this section, if any.
            NSIndexPath *oldCheckedIndexPath = nil;
            for (NSIndexPath *checkedIndexPath in self.checkedIndexPaths) {
                if (checkedIndexPath.section == indexPath.section) {
                    oldCheckedIndexPath = checkedIndexPath;
                    break;
                }
            }
            
            // Uncheck old row, remove it from contro array, check new one and add it to the array.
            [tableView cellForRowAtIndexPath:oldCheckedIndexPath].accessoryType = UITableViewCellAccessoryNone;
            [self.checkedIndexPaths removeObject:oldCheckedIndexPath];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [self.checkedIndexPaths addObject:indexPath];
        } break;
            
        case 2: {
            // If row already checked, uncheck it and vice-versa.
            if ([self.checkedIndexPaths containsObject:indexPath]) {
                [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
                [self.checkedIndexPaths removeObject:indexPath];
            } else {
                [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
                [self.checkedIndexPaths addObject:indexPath];
            }
        } break;
            
        default:
            break;
    }
    
    // Verify obligatory fields (Meal avaliation and local).
    NSUInteger obligatoryFields = 0;
    for (NSIndexPath *checkedIndexPath in self.checkedIndexPaths) {
        if (checkedIndexPath.section <= 1) {
            obligatoryFields++;
        }
    }
    
    // If the vote is filled with enough values, enable submit button.
    self.navigationItem.rightBarButtonItem.enabled = (obligatoryFields >= 2);
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set basic information (no matter vote is allowed or no).
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconVoteSelected"];
    self.checkedIndexPaths = [NSMutableArray array];
#warning Fix cached last vote.
//    self.lastVoteDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"LastVoteDate"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self adjustInterfaceForVoteStatus];
}

@end

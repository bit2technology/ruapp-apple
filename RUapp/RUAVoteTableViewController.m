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

NSString *const RUALastVoteDateKey = @"LastVoteDate";

@interface RUAVoteTableViewController () <UIAlertViewDelegate>

//@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSMutableArray *checkedIndexPaths;

@property (strong, nonatomic) NSDate *lastVoteDate;








@property (assign, nonatomic) BOOL presentVoteInterface;

// Strings lists
@property (strong, nonatomic) NSArray *avaliationList;
@property (strong, nonatomic) NSArray *restaurantsList;
@property (strong, nonatomic) NSArray *dishesList;
@property (strong, nonatomic) NSArray *headersList;

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
        //self.dataSource = nil;
        [self.checkedIndexPaths removeAllObjects];
        
        
        
        
        
        self.presentVoteInterface = NO;
    } else {
        //self.dataSource = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VoteDataSource" ofType:@"plist"]];
        self.tableView.backgroundView = nil;
        
        
        
        
        
        self.presentVoteInterface = YES;
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
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationTop];
        //self.dataSource = nil;
        self.presentVoteInterface = NO;
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
        [RUAServerConnection sendVoteWithRestaurant:restaurant vote:rating reason:dishes completionHandler:^(NSDate *voteDate, NSString *localizedMessage) {
            // If vote was successful
            if (voteDate) {
                self.lastVoteDate = voteDate;
                NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                [standardUserDefaults setValue:voteDate forKey:RUALastVoteDateKey];
                [standardUserDefaults synchronize];
                
                self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:localizedMessage];
            } else {
                //TODO:reload vote screen.
            }
        }];
    }
}

#pragma mark - UITableViewController methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.presentVoteInterface ? 3 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.presentVoteInterface) {
        switch (section) {
            case 0:
                return 4;
            case 1:
                return 2;
                
            default:
                return 7;
        };
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.presentVoteInterface) {
        return self.headersList[(NSUInteger)section];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Vote Cell" forIndexPath:indexPath];
    
    cell.accessoryType = ([self.checkedIndexPaths containsObject:indexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSString *text; UIImage *image;
    switch (indexPath.section) {
        case 0: {
            NSDictionary *rowInfo = self.avaliationList[(NSUInteger)indexPath.row];
            text = rowInfo[@"text"];
            image = [UIImage imageNamed:rowInfo[@"image"]];
        } break;
        case 1: {
            text = self.restaurantsList[(NSUInteger)indexPath.row];
        } break;
        default: {
            text = self.dishesList[(NSUInteger)indexPath.row];
        } break;
    }
    cell.textLabel.text = text;
    cell.imageView.image = image;
    
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

// MARK: UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set basic information (no matter vote is allowed or no).
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconVoteSelected"];
    self.checkedIndexPaths = [NSMutableArray array];
#warning Fix cached last vote.
//    self.lastVoteDate = [[NSUserDefaults standardUserDefaults] valueForKey:RUALastVoteDateKey];
    
    
    
    
    
    
    
    
    self.avaliationList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AvaliationList" ofType:@"plist"]];
    self.restaurantsList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RestaurantsList" ofType:@"plist"]];
    self.dishesList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DishesList" ofType:@"plist"]];
    self.headersList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VoteHeadersList" ofType:@"plist"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self adjustInterfaceForVoteStatus];
}

@end

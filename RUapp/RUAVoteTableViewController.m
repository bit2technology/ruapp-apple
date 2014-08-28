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

@property (assign, nonatomic) BOOL presentVoteInterface;
@property (assign, nonatomic) BOOL changeRestaurantAllowed;

// Data control
@property (strong, nonatomic) NSMutableArray *checkedIndexPaths;
@property (strong, nonatomic) NSDate *lastVoteDate;
@property (strong, nonatomic) NSDate *lastAppearance;
@property (assign, nonatomic) RUAMeal mealForNow;

// Strings lists
@property (strong, nonatomic) NSArray *avaliationList;
@property (strong, nonatomic) NSArray *mealList;
@property (strong, nonatomic) NSArray *restaurantsList;
@property (strong, nonatomic) NSArray *dishesList;
@property (strong, nonatomic) NSArray *headersList;

@end

@implementation RUAVoteTableViewController

- (void)adjustInterfaceForVoteStatus
{
    NSDate *now = [RUAAppDelegate sharedAppDelegate].date;
    self.lastAppearance = now;
    self.mealForNow = [RUAAppDelegate mealForDate:now];
    
    // If it is not time to vote, show appropriate interface.
    if (self.mealForNow == RUAMealNone) {
        self.presentVoteInterface = NO;
        [self.checkedIndexPaths removeAllObjects];
        self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:NSLocalizedString(@"Sorry, there is no vote open now.", @"Vote not Disponible Message")];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else
    // If there is a vote, and it has less than 5 hours and the meal is the same, then show "already voted" interface.
    if (self.lastVoteDate && [now timeIntervalSinceDate:self.lastVoteDate] <= 18000 && [RUAAppDelegate mealForDate:self.lastVoteDate] == self.mealForNow) {
        self.presentVoteInterface = NO;
        [self.checkedIndexPaths removeAllObjects];
        self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:NSLocalizedString(@"Thank you! Vote computed.", @"Vote Computed Message")];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        // Vote allowed. Check schedule.
        NSIndexPath *defaultRestaurantIndexPath;
        switch (self.mealForNow) {
            case RUAMealBreakfast:
            case RUAMealDinner: {
                defaultRestaurantIndexPath = [NSIndexPath indexPathForRow:1 inSection:1]; // Campus
            } break;
            case RUAMealLunch: {
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
                NSDateComponents *dateComponents = [gregorianCalendar components:NSCalendarUnitWeekday fromDate:now];
                if (dateComponents.weekday == 1) {
                    defaultRestaurantIndexPath = [NSIndexPath indexPathForRow:0 inSection:1]; // Downtown
                }
            } break;
            default:
                break;
        }
        // Remove old restaurant checked index path, insert new one and verify and update interface and behaviour accordingly.
        if (defaultRestaurantIndexPath) {
            NSIndexPath *oldCheckedIndexPath;
            for (NSIndexPath *checkedIndexPath in self.checkedIndexPaths) {
                if (checkedIndexPath.section == 1) {
                    oldCheckedIndexPath = checkedIndexPath;
                    break;
                }
            }
            [self.checkedIndexPaths removeObject:oldCheckedIndexPath];
            [self.checkedIndexPaths addObject:defaultRestaurantIndexPath];
            // Verify obligatory fields (Meal avaliation and local).
            NSUInteger obligatoryFields = 0;
            for (NSIndexPath *checkedIndexPath in self.checkedIndexPaths) {
                if (checkedIndexPath.section <= 1) {
                    obligatoryFields++;
                }
            }
            self.navigationItem.rightBarButtonItem.enabled = (obligatoryFields >= 2);
            self.changeRestaurantAllowed = NO;
            
        } else {
            self.changeRestaurantAllowed = YES;
        }
        self.presentVoteInterface = YES;
        self.tableView.backgroundView = nil;
    }
    [self.tableView reloadData];
}

- (void)setLastAppearance:(NSDate *)lastAppearance
{
    // If more than ten minutes.
    if ([lastAppearance timeIntervalSinceDate:_lastAppearance] >= 600) {
        [self.checkedIndexPaths removeAllObjects];
    }
    _lastAppearance = lastAppearance;
}

- (void)setMealForNow:(RUAMeal)mealForNow
{
    // If different from last appearance (viewWillAppear: call).
    if (mealForNow != _mealForNow) {
        [self.checkedIndexPaths removeAllObjects];
    }
    _mealForNow = mealForNow;
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
        self.presentVoteInterface = NO;
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationTop];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView startAnimating];
        self.tableView.backgroundView = activityView;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.tableView endUpdates];
        
        // Colect vote info.
        RUARating rating = RUARatingNone;
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
        [RUAServerConnection sendVoteWithRestaurant:restaurant rating:rating reason:dishes completionHandler:^(NSDate *voteDate, NSString *localizedMessage) {
            // If vote was successful
            if (voteDate) {
                self.lastVoteDate = voteDate;
                NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                [standardUserDefaults setValue:voteDate forKey:RUALastVoteDateKey];
                [standardUserDefaults synchronize];
                self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:localizedMessage];
            } else {
                // Present error alert and vote interface.
                self.presentVoteInterface = YES;
                [self.tableView beginUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationTop];
                self.tableView.backgroundView = nil;
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [self.tableView endUpdates];
                [[[UIAlertView alloc] initWithTitle:localizedMessage
                                            message:nil
                                           delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Vote Alert Cancel Button")
                                  otherButtonTitles:nil] show];
            }
        }];
    }
}

// MARK: UITableViewController methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.presentVoteInterface ? 3 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
        case 1:
            return 2;
            
        default:
            return 7;
    };
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.presentVoteInterface) {
        NSString *headersString = self.headersList[(NSUInteger)section];
        switch (section) {
            case 0:
                return [NSString stringWithFormat:headersString, self.mealList[self.mealForNow]];
                break;
            default: {
                return headersString;
            } break;
        }
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
            cell.selectionStyle = (self.changeRestaurantAllowed ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone);
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
    // Verify if restaurant can be changed.
    if (indexPath.section == 1 && !self.changeRestaurantAllowed) {
        return;
    }
    
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
    
    // Set basic information
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconVoteSelected"];
    
    // Data control
    self.checkedIndexPaths = [NSMutableArray array];
#warning Fix cached last vote.
    //self.lastVoteDate = [[NSUserDefaults standardUserDefaults] valueForKey:RUALastVoteDateKey];
    
    // Strings lists
    self.avaliationList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AvaliationList" ofType:@"plist"]];
    self.mealList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MealList" ofType:@"plist"]];
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

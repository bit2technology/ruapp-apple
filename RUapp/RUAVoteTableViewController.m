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

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSMutableArray *checkedIndexPaths;

@end

@implementation RUAVoteTableViewController

- (IBAction)submitVote:(id)sender
{
    // Present confirmation alert.
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to submit this vote?", @"Vote alert view title")
                                message:NSLocalizedString(@"The vote can't be changed after you send it.", @"Vote alert view message")
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Vote alert view cancel button")
                      otherButtonTitles:NSLocalizedString(@"Submit", @"Vote alert view submit button"), nil] show];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If clicked OK in confirmation alert.
    if (buttonIndex > 0) {
        RUARating rating = NSNotFound;
        RUARestaurant restaurant = NSNotFound;
        RUADish *dishes = malloc(RUADishTotal * sizeof(RUADish));
        for (NSUInteger i = 0; i < RUADishTotal; i++) {
            dishes[i] = RUADishNone;
        }
        
        NSUInteger dishCount = 0;
        for (NSIndexPath *checkedIndexPath in self.checkedIndexPaths) {
            switch (checkedIndexPath.section) {
                case 0: {
                    rating = (RUARating)checkedIndexPath.row;
                } break;
                case 1: {
                    restaurant = (RUARestaurant)checkedIndexPath.row;
                } break;
                case 2: {
                    dishes[dishCount++] = (RUADish)checkedIndexPath.row;
                } break;
                    
                default:
                    break;
            }
        }
        
        [RUAServerConnection sendVoteWithRestaurant:restaurant vote:rating reason:dishes completionHandler:^{
            // TODO: Completion handler.
            
            free(dishes);
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
    
    self.dataSource = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VoteDataSource" ofType:@"plist"]];
    self.checkedIndexPaths = [NSMutableArray array];
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconVoteSelected"];
}

@end

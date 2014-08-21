//
//  RUAResultsTableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 2014-06-01.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAResultsTableViewController.h"
#import "RUAColor.h"
#import "RUAServerConnection.h"

NSString *const RUAResultsDataSourceCacheKey = @"ResultsDataSourceCache";

@implementation RUAResultsTableViewCell

@end

@interface RUAResultsTableViewController ()

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *dishesList;
@property (assign, nonatomic) RUARestaurant restaurant;

@end

@implementation RUAResultsTableViewController

- (IBAction)segmentedControlDidChangeValue:(UISegmentedControl *)sender
{
    self.restaurant = (RUARestaurant)sender.selectedSegmentIndex;
    [self.tableView reloadData];
}

// MARK: UITableViewController methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.dataSource ? 4 : 0);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // If there is no data source, return nil. Otherwise, return localized string by section (meal name).
    if (!self.dataSource) {
        return nil;
    }
    switch (section) {
        case 0:
            return NSLocalizedString(@"Overview", @"Menu Table View Controller Section Title");
            break;
        case 1:
            return NSLocalizedString(@"Details", @"Menu Table View Controller Section Title");
            break;
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0: { // Overview
            RUAResultsTableViewCell *overviewCell = [tableView dequeueReusableCellWithIdentifier:@"Results Overview Cell" forIndexPath:indexPath];
            RUAResultInfo *result = self.dataSource[self.restaurant];
            overviewCell.infoLabel.text = [result.votes[(NSUInteger)indexPath.row] description];
            
            cell = overviewCell;
        } break;
        case 1: { // Details
            
        } break;
        default:
            break;
    }
    
    return cell;
}

// MARK: UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Adjusting interface.
//    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconMenuSelected"];
    self.refreshControl.tintColor = [RUAColor whiteColor];
    
    self.dishesList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VoteDataSource" ofType:@"plist"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If there is a cached data source, adjust current page. Otherwise, show downloading (for the first time) interface.
    if (!self.dataSource) {
        self.tableView.userInteractionEnabled = NO;
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView startAnimating];
        self.tableView.backgroundView = activityView;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [RUAServerConnection requestResultsWithCompletionHandler:^(NSArray *results, NSError *error) {
        [self.tableView beginUpdates];
        if (![results isEqualToArray:self.dataSource]) {
            self.dataSource = results;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        self.tableView.backgroundView = nil;
        [self.tableView endUpdates];
    }];
}

@end

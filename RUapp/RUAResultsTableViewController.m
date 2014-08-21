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
@property (strong, nonatomic) NSArray *labelsList;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.dataSource ? (section ? 7 : 4) : 0);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // If there is no data source, return nil. Otherwise, return localized string by section (meal name).
    if (!self.dataSource) {
        return nil;
    }
    return self.labelsList[(NSUInteger)section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    UIFont *bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    switch (indexPath.section) {
        case 0: { // Overview
            RUAResultsTableViewCell *overviewCell = [tableView dequeueReusableCellWithIdentifier:@"Results Overview Cell" forIndexPath:indexPath];
            RUAResultInfo *result = self.dataSource[self.restaurant];
            NSDictionary *info = self.labelsList[(NSUInteger)indexPath.section][@"rows"][(NSUInteger)indexPath.row];
            overviewCell.voteIconView.accessibilityLabel = info[@"text"];
            overviewCell.voteIconView.image = [UIImage imageNamed:info[@"image"]];
            overviewCell.helperLabel.font = bodyFont;
            overviewCell.infoLabel.font = bodyFont;
            overviewCell.infoLabel.text = [NSString stringWithFormat:@"%.1f%%", [result.votesText[(NSUInteger)indexPath.row] doubleValue] * 100];
            overviewCell.progressView.progress = [result.votesProgress[(NSUInteger)indexPath.row] floatValue];
            cell = overviewCell;
        } break;
        case 1: { // Details
            cell = [tableView dequeueReusableCellWithIdentifier:@"Results Detail Cell" forIndexPath:indexPath];
            cell.textLabel.font = bodyFont;
            cell.textLabel.text = self.labelsList[(NSUInteger)indexPath.section][@"rows"][(NSUInteger)indexPath.row];
            cell.detailTextLabel.font = bodyFont;
            cell.detailTextLabel.text = @"Count";
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
    
    self.labelsList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ResultsLabelsList" ofType:@"plist"]];
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
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
            self.tableView.userInteractionEnabled = YES;
            if (!self.navigationItem.titleView) {
                UISegmentedControl *titleView = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Downtown", @"Menu Table View Controller Section Title"), NSLocalizedString(@"Campus", @"Menu Table View Controller Section Title")]];
                CGRect titleViewFrame = titleView.frame;
                titleViewFrame.size.width = CGFLOAT_MAX;
                titleView.frame = titleViewFrame;
                titleView.selectedSegmentIndex = self.restaurant;
                [titleView addTarget:self action:@selector(segmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
                self.navigationItem.titleView = titleView;
            }
        }
        self.tableView.backgroundView = nil;
        [self.tableView endUpdates];
    }];
}

@end

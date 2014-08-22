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

@property (strong, nonatomic) NSArray *dataSourceComplete;
@property (strong, nonatomic) NSArray *labelsList;

@property (assign, nonatomic) RUARestaurant restaurant;
@property (readonly, nonatomic) RUAResultInfo *dataSource;
@property (assign, nonatomic) UITableViewRowAnimation rowAnimation;

@end

@implementation RUAResultsTableViewController

- (RUAResultInfo *)dataSource
{
    return self.dataSourceComplete[self.restaurant];
}

- (void)downloadResults
{
    [RUAServerConnection requestResultsWithCompletionHandler:^(NSArray *results, NSError *error) {
        [self.tableView beginUpdates];
        [self.refreshControl endRefreshing];
        self.tableView.backgroundView = nil;
        if (![results isEqualToArray:self.dataSourceComplete]) {
            if (self.dataSourceComplete) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                UISegmentedControl *titleView = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Downtown", @""), NSLocalizedString(@"Campus", @"")]];
                CGRect titleViewFrame = titleView.frame;
                titleViewFrame.size.width = CGFLOAT_MAX;
                titleView.frame = titleViewFrame;
                titleView.selectedSegmentIndex = self.restaurant;
                [titleView addTarget:self action:@selector(segmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
                [self segmentedControlDidChangeValue:titleView];
                self.navigationItem.titleView = titleView;
            }
            self.dataSourceComplete = results;
            self.tableView.userInteractionEnabled = YES;
        }
        [self.tableView endUpdates];
    }];
}

/**
 * Called when the user request an update (drag to refresh).
 */
- (IBAction)refreshControlDidChangeValue:(UIRefreshControl *)sender
{
    // If not refreshing or already downloading, end refresh and cancel.
    if (!sender.isRefreshing /*|| self.isDownloadingDataSource*/) {
        [sender endRefreshing];
        return;
    }
    
    [self downloadResults];
}

- (void)setRestaurant:(RUARestaurant)restaurant
{
    if (restaurant > _restaurant) {
        self.rowAnimation = UITableViewRowAnimationLeft;
    } else if (restaurant < _restaurant) {
        self.rowAnimation = UITableViewRowAnimationRight;
    } else {
        self.rowAnimation = UITableViewRowAnimationAutomatic;
    }
    _restaurant = restaurant;
}

- (IBAction)segmentedControlDidChangeValue:(UISegmentedControl *)sender
{
    self.restaurant = (RUARestaurant)sender.selectedSegmentIndex;
    if (self.dataSource.votesTotal) {
        self.tableView.backgroundView = nil;
    } else {
        self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:@"No votes yet.\n\nPull down to refresh."];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:self.rowAnimation];
}

// MARK: UITableViewController methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.dataSource.votesTotal ? (section ? 7 : 4) : 0);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // If there is no data source, return nil. Otherwise, return localized string by section (meal name).
    if (!self.dataSource.votesTotal) {
        return nil;
    }
    return self.labelsList[(NSUInteger)section][@"title"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (!self.dataSource.votesTotal) {
        return nil;
    }
    if (section == 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"Total of votes: %lu", @"Results Table Section Footer"), (unsigned long)self.dataSource.votesTotal];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    UIFont *bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    switch (indexPath.section) {
        case 0: { // Overview
            RUAResultsTableViewCell *overviewCell = [tableView dequeueReusableCellWithIdentifier:@"Results Overview Cell" forIndexPath:indexPath];
            NSDictionary *info = self.labelsList[(NSUInteger)indexPath.section][@"rows"][(NSUInteger)indexPath.row];
            overviewCell.voteIconView.accessibilityLabel = info[@"text"];
            overviewCell.voteIconView.image = [UIImage imageNamed:info[@"image"]];
            overviewCell.helperLabel.font = bodyFont;
            overviewCell.infoLabel.font = bodyFont;
            overviewCell.infoLabel.text = [NSString stringWithFormat:@"%.1f%%", [self.dataSource.votesText[(NSUInteger)indexPath.row] doubleValue] * 100];
            overviewCell.progressView.progress = [self.dataSource.votesProgress[(NSUInteger)indexPath.row] floatValue];
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
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconResultsSelected"];
    self.refreshControl.tintColor = [RUAColor whiteColor];
    
    self.rowAnimation = UITableViewRowAnimationAutomatic;
    self.labelsList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ResultsLabelsList" ofType:@"plist"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If there is a cached data source, adjust current page. Otherwise, show downloading (for the first time) interface.
    if (!self.dataSourceComplete) {
        self.tableView.userInteractionEnabled = NO;
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView startAnimating];
        self.tableView.backgroundView = activityView;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self downloadResults];
}

@end

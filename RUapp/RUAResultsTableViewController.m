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

@property (strong, nonatomic) NSArray *resultsListRaw;
@property (strong, nonatomic) NSArray *avaliationList;

@property (assign, nonatomic) RUARestaurant restaurant;
@property (readonly, nonatomic) RUAResultInfo *resultsList;

@end

@implementation RUAResultsTableViewController

- (RUAResultInfo *)resultsList
{
    return self.resultsListRaw[self.restaurant];
}

- (void)downloadResults
{
    [RUAServerConnection requestResultsWithCompletionHandler:^(NSArray *results, NSString *localizedMessage) {
        [self.tableView beginUpdates];
        [self.refreshControl endRefreshing];
        self.tableView.backgroundView = nil;
        if (![results isEqualToArray:self.resultsListRaw]) {
            if (self.resultsListRaw) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                NSArray *restaurantsList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RestaurantsList" ofType:@"plist"]];
                UISegmentedControl *titleView = [[UISegmentedControl alloc] initWithItems:restaurantsList];
                CGRect titleViewFrame = titleView.frame;
                titleViewFrame.size.width = CGFLOAT_MAX;
                titleView.frame = titleViewFrame;
                titleView.selectedSegmentIndex = self.restaurant;
                [titleView addTarget:self action:@selector(segmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
                [self segmentedControlDidChangeValue:titleView];
                self.navigationItem.titleView = titleView;
            }
            self.resultsListRaw = results;
            self.tableView.userInteractionEnabled = YES;
            self.tableView.backgroundView = nil;
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

- (IBAction)segmentedControlDidChangeValue:(UISegmentedControl *)sender
{
    RUARestaurant newRestaurant = (RUARestaurant)sender.selectedSegmentIndex;
    UITableViewRowAnimation rowAnimation;
    if (newRestaurant > self.restaurant) {
        rowAnimation = UITableViewRowAnimationLeft;
    } else if (newRestaurant < self.restaurant) {
        rowAnimation = UITableViewRowAnimationRight;
    } else {
        rowAnimation = UITableViewRowAnimationAutomatic;
    }
    if (self.resultsList.votesTotal) {
        self.tableView.backgroundView = nil;
    } else {
        self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:@"No votes yet.\n\nPull down to refresh."];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:rowAnimation];
}

// MARK: UITableViewController methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.resultsList.votesTotal ? 4 : 0);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // If there is no data source, return nil. Otherwise, return localized string by section (meal name).
    if (!self.resultsList.votesTotal) {
        return nil;
    }
    return @"blablabla";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (!self.resultsList.votesTotal) {
        return nil;
    }
    if (section == 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"Total of votes: %lu", @"Results Table Section Footer"), (unsigned long)self.resultsList.votesTotal];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44;
    }
    
    // Calculate height for each row.
    NSString *mealText = self.resultsList.reasons[(NSUInteger)indexPath.row];
    CGSize referenceSize = CGRectInfinite.size;
    referenceSize.width = 193;
    CGFloat actualHeight = [mealText boundingRectWithSize:referenceSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil].size.height + 16;
    CGFloat height = (actualHeight > 44 ? actualHeight : 44);
    return (CGFloat)floorl(height);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIFont *bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSDictionary *rowInfo = self.avaliationList[(NSUInteger)indexPath.row];
    NSString *avaliationText = rowInfo[@"text"];
    
    
    
    RUAResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Results Overview Cell" forIndexPath:indexPath];
    cell.helperLabel.font = bodyFont;
    cell.voteIconView.accessibilityLabel = avaliationText;
    cell.voteIconView.image = [UIImage imageNamed:rowInfo[@"image"]];
    cell.infoLabel.font = bodyFont;
    cell.infoLabel.text = [NSString stringWithFormat:@"%.1f%%", [self.resultsList.votesText[(NSUInteger)indexPath.row] floatValue] * 100];
    
    
    
    switch (indexPath.section) {
        case 0: { // Overview
            cell.progressView.hidden = NO;
            cell.progressView.progress = [self.resultsList.votesProgress[(NSUInteger)indexPath.row] floatValue];
            cell.progressView.progressTintColor = [UIColor colorWithCIColor:[CIColor colorWithString:rowInfo[@"color"]]];
            cell.dishLabel.hidden = YES;
        } break;
        default: { // Details
            cell.dishLabel.font = bodyFont;
            cell.dishLabel.hidden = NO;
            cell.dishLabel.numberOfLines = NSIntegerMax;
            cell.dishLabel.text = self.resultsList.reasons[(NSUInteger)indexPath.row];
            cell.progressView.hidden = YES;
        } break;
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
    
    // Strings lists
    self.avaliationList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AvaliationList" ofType:@"plist"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If there is a cached data source, adjust current page. Otherwise, show downloading (for the first time) interface.
    if (!self.resultsListRaw) {
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

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
@property (strong, nonatomic) NSArray *headersList;
@property (strong, nonatomic) NSArray *mealList;

@property (assign, nonatomic) RUARestaurant restaurant;
@property (readonly, nonatomic) RUAResultInfo *resultsList;
@property (strong, nonatomic) NSDate *lastAppearance;
@property (assign, nonatomic) BOOL isDownloading;

@end

@implementation RUAResultsTableViewController

// MARK: Properties

- (RUAResultInfo *)resultsList
{
    return self.resultsListRaw[self.restaurant];
}

// MARK: Methods

- (void)downloadResultsAndUpdateTable
{
    self.isDownloading = YES;
    [RUAServerConnection requestResultsWithCompletionHandler:^(NSArray *results, NSString *localizedMessage) {
        if (results) { // If results downloaded
            if (![results isEqualToArray:self.resultsListRaw]) { // If downloaded results is different from previous results
                [self.tableView beginUpdates];
                self.resultsListRaw = results;
                // If there is no title view (segmented control) create one
                if (!self.navigationItem.titleView) {
                    NSArray *restaurantsList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RestaurantsList" ofType:@"plist"]];
                    UISegmentedControl *titleView = [[UISegmentedControl alloc] initWithItems:restaurantsList];
                    CGRect titleViewFrame = titleView.frame;
                    titleViewFrame.size.width = CGFLOAT_MAX;
                    titleView.frame = titleViewFrame;
                    titleView.selectedSegmentIndex = self.restaurant;
                    [titleView addTarget:self action:@selector(segmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
                    self.navigationItem.titleView = titleView;
                }
                [self segmentedControlDidChangeValue:(UISegmentedControl *)self.navigationItem.titleView]; // Also reloads the table view
                [self.tableView endUpdates];
            }
        } else if (!self.resultsListRaw) {
            self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:localizedMessage];
        }
        self.isDownloading = NO;
        self.tableView.userInteractionEnabled = YES;
        [self.refreshControl endRefreshing];
    }];
}

/**
 * Called when the user request an update (drag to refresh).
 */
- (IBAction)refreshControlDidChangeValue:(UIRefreshControl *)sender
{
    // If not refreshing or already downloading, end refresh and cancel.
    if (!sender.isRefreshing || self.isDownloading) {
        [sender endRefreshing];
        return;
    }
    
    [self downloadResultsAndUpdateTable];
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
    
    self.restaurant = newRestaurant;
    
    if (self.resultsList.votesTotal) {
        self.tableView.backgroundView = nil;
        self.tableView.tableHeaderView = nil;
    } else {
        self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:@"No votes yet"];
        self.tableView.tableHeaderView = [self tableViewBackgroundViewWithMessage:@"Pull down to refresh"];
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
    return [NSString stringWithFormat:self.headersList[(NSUInteger)section], self.mealList[[RUAAppDelegate lastMealForNow]]];
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
    NSString *mealText = self.resultsList.reasons[(NSUInteger)indexPath.row][@"dishes"];
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
    
    
    
    RUAResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Results Cell" forIndexPath:indexPath];
    cell.helperLabel.font = bodyFont;
    cell.voteIconView.accessibilityLabel = avaliationText;
    cell.voteIconView.image = [UIImage imageNamed:rowInfo[@"image"]];
    cell.infoLabel.font = bodyFont;
    
    
    
    NSNumber *percent;
    switch (indexPath.section) {
        case 0: { // Overview
            percent = self.resultsList.votesText[(NSUInteger)indexPath.row];
            cell.progressView.hidden = NO;
            cell.progressView.progress = [self.resultsList.votesProgress[(NSUInteger)indexPath.row] floatValue];
            cell.progressView.progressTintColor = [UIColor colorWithCIColor:[CIColor colorWithString:rowInfo[@"color"]]];
            cell.dishLabel.hidden = YES;
        } break;
        default: { // Details
            percent = self.resultsList.reasons[(NSUInteger)indexPath.row][@"percent"];
            cell.dishLabel.font = bodyFont;
            cell.dishLabel.hidden = NO;
            cell.dishLabel.numberOfLines = NSIntegerMax;
            cell.dishLabel.text = self.resultsList.reasons[(NSUInteger)indexPath.row][@"dishes"];
            cell.progressView.hidden = YES;
        } break;
    }
    cell.infoLabel.text = [NSString stringWithFormat:@"%.1f%%", [percent floatValue] * 100];
    
    return cell;
}

// MARK: UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Adjusting interface
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconResultsSelected"];
    self.refreshControl.layer.zPosition = CGFLOAT_MAX;
    self.refreshControl.tintColor = [RUAColor whiteColor];
    
    // Strings lists
    self.avaliationList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AvaliationList" ofType:@"plist"]];
    self.headersList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ResultsHeadersList" ofType:@"plist"]];
    self.mealList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MealList" ofType:@"plist"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDate *now = [RUAAppDelegate sharedAppDelegate].date, *lastAppearance = self.lastAppearance.copy;
    // If there is no last appearance or more than 19 hours or last meal for now is different from last meal for last appearance, remove results list.
    if (!lastAppearance || [now timeIntervalSinceDate:lastAppearance] >= 68400 || [RUAAppDelegate lastMealForDate:&now] != [RUAAppDelegate lastMealForDate:&lastAppearance]) {
        self.resultsListRaw = nil;
        [self.tableView reloadData];
    }
    
    // If there isn't a results list, show downloading (for the first time) interface.
    if (!self.resultsListRaw) {
        self.navigationItem.titleView = nil;
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView startAnimating];
        self.tableView.backgroundView = activityView;
        self.tableView.userInteractionEnabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.lastAppearance = [RUAAppDelegate sharedAppDelegate].date;
    [self downloadResultsAndUpdateTable];
}

@end

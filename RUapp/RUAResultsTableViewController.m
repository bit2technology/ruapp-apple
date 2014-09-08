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

// Main data
@property (strong, nonatomic) NSArray *resultsListRaw;
@property (readonly, nonatomic) RUAResultInfo *resultsList;

// Labels
@property (strong, nonatomic) NSArray *avaliationList;
@property (strong, nonatomic) NSArray *headersList;
@property (strong, nonatomic) NSArray *mealList;

// Other controls
@property (assign, nonatomic) BOOL isDownloading;
@property (assign, nonatomic) RUARestaurant restaurant;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

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
                if (self.resultsList.meal == RUAMealLunch) {
                    self.segmentedControl.selectedSegmentIndex = (NSInteger)RUARestaurantJuizDeForaDowntown;
                    self.restaurant = RUARestaurantJuizDeForaDowntown;
                    self.navigationItem.titleView = self.segmentedControl;
                } else {
                    self.navigationItem.titleView = nil;
                    self.segmentedControl.selectedSegmentIndex = (NSInteger)RUARestaurantJuizDeForaCampus;
                    self.restaurant = RUARestaurantJuizDeForaCampus;
                }
                [self segmentedControlDidChangeValue:(UISegmentedControl *)self.navigationItem.titleView]; // Also reloads the table view
                [self.tableView endUpdates];
            }
        } else if (!self.resultsListRaw) {
            self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:localizedMessage];
            self.tableView.tableHeaderView = self.tableViewHeaderViewPullToRefresh;
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
    UITableViewRowAnimation rowAnimation;
    if (sender) {
        RUARestaurant newRestaurant = (RUARestaurant)sender.selectedSegmentIndex;
        if (newRestaurant > self.restaurant) {
            rowAnimation = UITableViewRowAnimationLeft;
        } else if (newRestaurant < self.restaurant) {
            rowAnimation = UITableViewRowAnimationRight;
        } else {
            rowAnimation = UITableViewRowAnimationAutomatic;
        }
        self.restaurant = newRestaurant;
    } else {
        rowAnimation = UITableViewRowAnimationAutomatic;
    }
    
    if (self.resultsList.votesTotal) {
        self.tableView.backgroundView = nil;
        self.tableView.tableHeaderView = nil;
    } else {
        self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:NSLocalizedString(@"No votes yet", @"Background message for when there was no vote for last meal")];
        self.tableView.tableHeaderView = self.tableViewHeaderViewPullToRefresh;
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
    // Hide details for breakfast
    if (self.resultsList.votesTotal) {
        if (self.resultsList.meal != RUAMealBreakfast || section != 1) {
            return 4;
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // If there is no data source, return nil. Otherwise, return localized string by section (meal name).
    if (!self.resultsList.votesTotal) {
        return nil;
    }
    // Hide for breakfast
    if (self.resultsList.meal != RUAMealBreakfast || section != 1) {
        return [NSString stringWithFormat:self.headersList[(NSUInteger)section], self.mealList[self.resultsList.meal]];
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (!self.resultsList.votesTotal) {
        return nil;
    }
    if (section == 0) {
        return [NSString localizedStringWithFormat:NSLocalizedString(@"Total of votes: %lu", @"Overview section footer"), (unsigned long)self.resultsList.votesTotal];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44;
    }
    
    // Calculate height for each row on second section.
    NSString *mealText = self.resultsList.reasons[(NSUInteger)indexPath.row][@"dishes"];
    CGSize referenceSize = CGRectInfinite.size;
    UIFont *bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    CGFloat helperLabelWidth = [@"100%" boundingRectWithSize:referenceSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: bodyFont} context:nil].size.width;
    referenceSize.width = tableView.bounds.size.width - helperLabelWidth - 71;
    CGFloat actualHeight = [mealText boundingRectWithSize:referenceSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: bodyFont} context:nil].size.height + 16;
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
            cell.infoLabel.hidden = NO;
        } break;
        default: { // Details
            percent = self.resultsList.reasons[(NSUInteger)indexPath.row][@"percent"];
            cell.dishLabel.font = bodyFont;
            cell.dishLabel.hidden = NO;
            cell.dishLabel.numberOfLines = NSIntegerMax;
            NSString *reasons = self.resultsList.reasons[(NSUInteger)indexPath.row][@"dishes"];
            cell.dishLabel.text = (reasons ?: NSLocalizedString(@"No information", @"Message to show when there is no information about vote reason"));
            cell.infoLabel.hidden = (reasons ? NO : YES);
            cell.progressView.hidden = YES;
        } break;
    }
    //NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    cell.infoLabel.text = [NSNumberFormatter localizedStringFromNumber:percent numberStyle:NSNumberFormatterPercentStyle];
    
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
    
    // Create segmented control to use later
    NSArray *restaurantsList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RestaurantsList" ofType:@"plist"]];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:restaurantsList];
    CGRect titleViewFrame = segmentedControl.frame;
    titleViewFrame.size.width = CGFLOAT_MAX;
    segmentedControl.frame = titleViewFrame;
    segmentedControl.selectedSegmentIndex = (NSInteger)RUARestaurantJuizDeForaDowntown;
    [segmentedControl addTarget:self action:@selector(segmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl = segmentedControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDate *now = [RUAAppDelegate sharedAppDelegate].date;
    // If there is no results' date or it has more than 19 hours or last meal for now is different from results' meal, remove results list.
    if (!self.resultsList.date || [now timeIntervalSinceDate:self.resultsList.date] >= 68400 || [RUAAppDelegate lastMealForNow] != self.resultsList.meal) {
        self.resultsListRaw = nil;
        [self.tableView reloadData];
    }
    
    // If there isn't a results list, show downloading (for the first time) interface.
    if (!self.resultsListRaw) {
        self.navigationItem.titleView = nil;
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView startAnimating];
        self.tableView.backgroundView = activityView;
        self.tableView.tableHeaderView = nil;
        self.tableView.userInteractionEnabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self downloadResultsAndUpdateTable];
}

@end

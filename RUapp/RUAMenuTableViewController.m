//
//  RUAMenuTableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAMenuTableViewController.h"
#import "RUAColor.h"
#import "RUAServerConnection.h"

NSString *const RUAMenuDataSourceCacheKey = @"MenuDataSourceCache";

@interface RUAMenuTableViewController ()

// Main model.
@property (strong, nonatomic) NSArray *menuDishesList;
@property (strong, nonatomic) NSArray *dataSource;
@property (assign, nonatomic) BOOL isDownloadingDataSource;

// Navigation information.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousPage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextPage;
@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRight;
@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeft;
@property (assign, nonatomic) NSInteger currentPage;
@property (strong, nonatomic) NSArray *weekdays;

@end

@implementation RUAMenuTableViewController

/**
 * Adjusts current page for week day;
 */
- (void)adjustCurrentPage
{
    // Set current page by getting weekday from date components.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    NSDateComponents *dateComponents = [gregorianCalendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    self.currentPage = dateComponents.weekday - 2; // Adjusting to 0 based count and monday based weekend.
}

/**
 * Returns the appropriate array for section and current page.
 */
- (NSArray *)mealMenuForCurrentPageForSection:(NSInteger)section
{
    return self.dataSource[(NSUInteger)(self.currentPage * 2 + section)];
}

/**
 * Called when the user taps one of the buttons of navigation bar.
 */
- (IBAction)changePage:(id)sender
{
    // Preparing to go to previous or next page.
    UITableViewRowAnimation rowAnimation = UITableViewRowAnimationNone;
    if (sender == self.previousPage || sender == self.swipeRight) {
        self.currentPage--;
        rowAnimation = UITableViewRowAnimationRight;
    } else if (sender == self.nextPage || sender == self.swipeLeft) {
        self.currentPage++;
        rowAnimation = UITableViewRowAnimationLeft;
    }
    // Performing page change.
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:rowAnimation];
}

- (void)downloadDataSourceAndUpdateTable
{
    self.isDownloadingDataSource = YES;
    [RUAServerConnection requestMenuForWeekWithCompletionHandler:^(NSArray *weekMenu, NSError *error) {
        if (error) {
            NSLog(@"Menu error: %@", error.localizedDescription);
        }
        // If successful (weekMenu != nil), show menu. Otherwise, show error message.
        if (weekMenu) {
            // Perform changes only if new week menu is different from previous.
            if (![weekMenu isEqualToArray:self.dataSource]) {
                // If there is no data source (is first download, not an update), adjust current page.
                if (!self.dataSource) {
                    [self adjustCurrentPage];
                    self.tableView.backgroundView = nil;
                    self.tableView.userInteractionEnabled = YES;
                }
                
                // Cache week menu.
                [[NSUserDefaults standardUserDefaults] setValue:weekMenu forKey:RUAMenuDataSourceCacheKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Perform updates.
                [self.tableView beginUpdates];
                self.dataSource = weekMenu;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        } else {
            // If there is no data source (is first download, not an update), show an appropriate message. Otherwise, do nothing.
            if (!self.dataSource) {
                NSString *info = (error ?
                                  NSLocalizedString(@"Couldn't download menu", @"Menu Error Description") :
                                  NSLocalizedString(@"Menu not available for this week", @"Menu Error Description"));
                self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:info];
            }
        }
        self.isDownloadingDataSource = NO;
        [self.refreshControl endRefreshing];
    }];
}

/**
 * Called when the user request an update (drag to refresh).
 */
- (IBAction)refreshControlDidChangeValue:(UIRefreshControl *)sender
{
    // If not refreshing or already downloading, end refresh and cancel.
    if (!sender.isRefreshing || self.isDownloadingDataSource) {
        [sender endRefreshing];
        return;
    }
    
    [self downloadDataSourceAndUpdateTable];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    // Disable or enable buttons by current page and change title.
    self.previousPage.enabled = (currentPage > 0);
    self.swipeRight.enabled = (currentPage > 0);
    self.nextPage.enabled = (currentPage < 6);
    self.swipeLeft.enabled = (currentPage < 6);
    self.navigationItem.title = [self.weekdays[(NSUInteger)currentPage] capitalizedString];
    _currentPage = currentPage;
}

// MARK: UITableViewController methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Lunch and dinner.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // If there is no data source, return 0. Otherwise, return 7 (dishes count).
    return (self.dataSource ? (NSInteger)[self mealMenuForCurrentPageForSection:section].count : 0);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // If there is no data source, return nil. Otherwise, return localized string by section (meal name).
    if (!self.dataSource) {
        return nil;
    }
    switch (section) {
        case 0:
            return NSLocalizedString(@"Lunch", @"Menu Table View Controller Section Title");
            break;
        case 1:
            return NSLocalizedString(@"Dinner", @"Menu Table View Controller Section Title");
            break;
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Calculate height for each row.
    NSString *mealText = [self mealMenuForCurrentPageForSection:indexPath.section][(NSUInteger)indexPath.row];
    CGSize referenceSize = CGRectInfinite.size;
    referenceSize.width = 193;
    CGFloat actualHeight = [mealText boundingRectWithSize:referenceSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil].size.height + 16;
    return (actualHeight > 44 ? actualHeight : 44);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dayly menu.
    NSArray *mealMenu = [self mealMenuForCurrentPageForSection:indexPath.section];
    
    // If menu has only one item, it means the restaurant is closed.
    UITableViewCell *cell;
    if (mealMenu.count > 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Menu Cell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.textLabel.text = self.menuDishesList[(NSUInteger)indexPath.row];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.detailTextLabel.numberOfLines = NSIntegerMax;
        cell.detailTextLabel.text = mealMenu[(NSUInteger)indexPath.row];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Menu Info Cell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.textLabel.text = NSLocalizedString(@"Restaurant closed", @"Menu Table View Controller Restaurant Info");
    }
    
    return cell;
}

// MARK: UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Adjusting interface.
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconMenuSelected"];
    self.refreshControl.tintColor = [UIColor whiteColor];
    
    self.menuDishesList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DishesList" ofType:@"plist"]];
#warning Activate cached menu.
//    self.dataSource = [[NSUserDefaults standardUserDefaults] valueForKey:RUAMenuDataSourceCacheKey];
    
    // Set array from date formatter to create appropriate title strings.
    NSLocale *bundleLocale = [NSLocale localeWithLocaleIdentifier:[[[NSBundle mainBundle] preferredLocalizations] firstObject]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = bundleLocale;
    NSMutableArray *weekdays = dateFormatter.weekdaySymbols.mutableCopy;
    // Move sunday to the end of array.
    NSString *sunday = weekdays.firstObject;
    [weekdays removeObjectAtIndex:0];
    [weekdays addObject:sunday];
    self.weekdays = weekdays;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If there is a cached data source, adjust current page. Otherwise, show downloading (for the first time) interface.
    if (self.dataSource) {
        [self adjustCurrentPage];
    } else {
        self.tableView.userInteractionEnabled = NO;
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView startAnimating];
        self.tableView.backgroundView = activityView;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Download or update menu.
    [self downloadDataSourceAndUpdateTable];
}

@end

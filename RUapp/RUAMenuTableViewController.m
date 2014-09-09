//
//  RUAMenuTableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAColor.h"
#import "RUAMenuTableViewController.h"
#import "RUAServerConnection.h"

NSString *const RUAMenuDataSourceCacheKey = @"MenuDataSourceCache";
NSString *const RUAMenuUpdated = @"MenuUpdated";

@interface RUAMenuTableViewController ()

@property (assign, nonatomic) BOOL isDownloading;

// MARK: Main model
@property (strong, nonatomic) NSArray *mealList;
@property (strong, nonatomic) NSArray *dishesList;
@property (strong, nonatomic) NSDictionary *menuListRaw;
@property (readonly, nonatomic) NSArray *menuList;
@property (readonly, nonatomic) NSInteger menuListWeekOfYear;
@property (strong, nonatomic) NSArray *weekdaysList;

// MARK: Navigation information
@property (assign, nonatomic) NSInteger currentPage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextPage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousPage;
@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeft;
@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRight;

@end

@implementation RUAMenuTableViewController

// MARK: Properties

/**
 * Helper for menu list.
 */
- (NSArray *)menuList
{
    return self.menuListRaw[@"Menu"];
}

/**
 * Helper for menu list's week of year.
 */
- (NSInteger)menuListWeekOfYear
{
    return [self.menuListRaw[@"WeekOfYear"] integerValue];
}

// MARK: Methods

- (void)downloadDataSourceAndUpdateTable
{
    self.isDownloading = YES;
    [RUAServerConnection requestMenuForWeekWithCompletionHandler:^(NSDictionary *weekMenu, NSString *localizedMessage) {
        // If successful (weekMenu != nil), show menu. Otherwise, show error message.
        if (weekMenu) {
            // Perform changes only if new week menu is different from previous.
            if (![weekMenu isEqualToDictionary:self.menuListRaw]) {
                // If there is no data source (is first download, not an update), adjust current page.
                if (!self.menuList) {
                    [self adjustCurrentPage];
                    self.tableView.backgroundView = nil;
                    self.tableView.tableHeaderView = nil;
                }
                
                // Cache week menu.
                [[NSUserDefaults standardUserDefaults] setValue:weekMenu forKey:RUAMenuDataSourceCacheKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Perform updates.
                [self.tableView beginUpdates];
                self.menuListRaw = weekMenu;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
                
                // Send notification
                [[NSNotificationCenter defaultCenter] postNotificationName:RUAMenuUpdated object:[self menuForCurrentMeal]];
            }
        } else {
            // If there is no data source (is first download, not an update), show an appropriate message and button to go to website. Otherwise, do nothing.
            if (!self.menuList) {
                UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
                UIView *pullToRefreshLabel = self.tableViewHeaderViewPullToRefresh;
                pullToRefreshLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                pullToRefreshLabel.translatesAutoresizingMaskIntoConstraints = YES;
                [tableHeaderView addSubview:pullToRefreshLabel];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                NSString *buttonTitle = NSLocalizedString(@"Open in Safari", @"Button title to open menu on Safari");
                CGRect buttonFrame = [buttonTitle boundingRectWithSize:tableHeaderView.bounds.size options:kNilOptions attributes:@{NSFontAttributeName: button.titleLabel.font} context:nil];
                buttonFrame.size.width += 16;
                button.frame = CGRectMake((tableHeaderView.bounds.size.width - buttonFrame.size.width) / 2, 44, buttonFrame.size.width, 44);
                button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
                button.translatesAutoresizingMaskIntoConstraints = YES;
                button.layer.borderColor = [RUAColor lightBlueColor].CGColor;
                button.layer.borderWidth = 1;
                button.layer.cornerRadius = 4;
                [button setBackgroundImage:[self imageWithColor:[RUAColor darkBlueColor]] forState:UIControlStateNormal];
                [button setBackgroundImage:[self imageWithColor:[RUAColor lightBlueColor]] forState:UIControlStateHighlighted];
                [button setTitle:buttonTitle forState:UIControlStateNormal];
                [button addTarget:self action:@selector(openInSafari) forControlEvents:UIControlEventTouchUpInside];
                [tableHeaderView addSubview:button];
                
                self.tableView.backgroundView = [self tableViewBackgroundViewWithMessage:localizedMessage];
                self.tableView.tableHeaderView = tableHeaderView;
            }
        }
        self.isDownloading = NO;
        [self.refreshControl endRefreshing];
        self.tableView.userInteractionEnabled = YES;
    }];
}

- (NSArray *)menuForCurrentMeal
{
    return [self menuForMeal:[RUAAppDelegate mealForNow]];
}

- (NSArray *)menuForMeal:(RUAMeal)meal
{
    // Return only if lunch or dinner
    if (meal != RUAMealLunch && meal != RUAMealDinner) {
        return nil;
    }
    NSDateComponents *dateComponents = [self adjustedDateComponents];
    NSArray *menu = self.menuList[(NSUInteger)dateComponents.weekday * 2 + (meal - 1)]; // Deconsider breakfast
    return (menu.count >= 7 ? menu : nil);
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    // Disable or enable buttons by current page and change title.
    self.previousPage.enabled = (currentPage > 0);
    self.swipeRight.enabled = (currentPage > 0);
    self.nextPage.enabled = (currentPage < 6);
    self.swipeLeft.enabled = (currentPage < 6);
    self.navigationItem.title = [self.weekdaysList[(NSUInteger)currentPage] capitalizedString];
    _currentPage = currentPage;
}

// MARK: Helper methods

/**
 * Adjusts current page for week day;
 */
- (void)adjustCurrentPage
{
    NSDateComponents *dateComponents = [self adjustedDateComponents];
    self.currentPage = dateComponents.weekday;
}

/**
 * Returns adjusted date components for weekday and weekOfYear.
 */
- (NSDateComponents *)adjustedDateComponents
{
    // Set current page by getting weekday from date components.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    NSDateComponents *dateComponents = [gregorianCalendar components:NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear fromDate:[RUAAppDelegate sharedAppDelegate].date];
    // Adjusting to 0 based count and monday based weekend.
    if (dateComponents.weekday == 1) {
        dateComponents.weekday += 7;
        dateComponents.weekOfYear--;
    }
    dateComponents.weekday -= 2;
    return dateComponents;
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

/**
 * Returns an image from a color.
 */
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 * Returns the appropriate array for section and current page.
 */
- (NSArray *)mealMenuForCurrentPageForSection:(NSInteger)section
{
    return self.menuList[(NSUInteger)(self.currentPage * 2 + section)];
}

- (void)openInSafari
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ufjf.br/ru/cardapio/"]];
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
    
    [self downloadDataSourceAndUpdateTable];
}

// MARK: UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Lunch and dinner
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // If there is no data source, return 0. Otherwise, return the smaller count between dishes and menu (to prevent any change in the server) or 1 if restaurant closed.
    if (self.menuList) {
        return (NSInteger)MIN([self mealMenuForCurrentPageForSection:section].count, self.dishesList.count);
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Calculate height for each row.
    NSString *mealText = [self mealMenuForCurrentPageForSection:indexPath.section][(NSUInteger)indexPath.row];
    CGSize referenceSize = CGRectInfinite.size;
    referenceSize.width = tableView.bounds.size.width - (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 ? 128 : 127); // Different sizes for iOS version
    CGFloat actualHeight = [mealText boundingRectWithSize:referenceSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil].size.height + 16;
    return (CGFloat)floorl(actualHeight > 44 ? actualHeight : 44);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // If there is a menu list, return meal name.
    if (self.menuList) {
        return self.mealList[(NSUInteger)section + 1]; // Deconsider breakfast
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dayly menu
    NSArray *mealMenu = [self mealMenuForCurrentPageForSection:indexPath.section];
    
    // If menu has only one item, it means the restaurant is closed.
    UITableViewCell *cell;
    if (mealMenu.count > 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Menu Cell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.textLabel.text = self.dishesList[(NSUInteger)indexPath.row];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.detailTextLabel.numberOfLines = NSIntegerMax;
        cell.detailTextLabel.text = mealMenu[(NSUInteger)indexPath.row];
        cell.detailTextLabel.textColor = [RUAColor whiteColor];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Menu Info Cell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.textLabel.text = [mealMenu[(NSUInteger)indexPath.row] capitalizedString];
        cell.textLabel.textColor = [RUAColor whiteColor];
    }
    
    return cell;
}

// MARK: UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Adjusting interface.
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconMenuSelected"];
    self.refreshControl.layer.zPosition = CGFLOAT_MAX;
    self.refreshControl.tintColor = [RUAColor whiteColor];
    
    [RUAAppDelegate sharedAppDelegate].menuTableViewController = self;
    self.mealList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MealList" ofType:@"plist"]];
    self.dishesList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DishesList" ofType:@"plist"]];
    // Set array from date formatter to create appropriate title strings.
    NSLocale *bundleLocale = [NSLocale localeWithLocaleIdentifier:[[NSBundle mainBundle] preferredLocalizations].firstObject];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = bundleLocale;
    NSMutableArray *weekdays = dateFormatter.weekdaySymbols.mutableCopy;
    // Move sunday to the end of array.
    NSString *sunday = weekdays.firstObject;
    [weekdays removeObjectAtIndex:0];
    [weekdays addObject:sunday];
    self.weekdaysList = weekdays;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.menuListRaw = [standardUserDefaults valueForKey:RUAMenuDataSourceCacheKey];
    // If there is a cached data source and is current week, adjust current page.
    if (self.menuListWeekOfYear == [self adjustedDateComponents].weekOfYear) {
        [self adjustCurrentPage];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If there isn't a cached data source, show downloading (for the first time) interface.
    if (self.menuListWeekOfYear != [self adjustedDateComponents].weekOfYear) {
        self.menuListRaw = nil;
        [self.tableView reloadData];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView startAnimating];
        self.tableView.backgroundView = activityView;
        self.tableView.userInteractionEnabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.title = NSLocalizedString(@"Menu", @"Menu table view controller default title");
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Download or update menu.
    [self downloadDataSourceAndUpdateTable];
}

@end

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

@interface RUAMenuTableViewController ()

// Main model.
@property (strong, nonatomic) NSArray *menuDishesList;
@property (strong, nonatomic) NSArray *dataSource;

// Navigation information.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousPage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextPage;
@property (assign, nonatomic) NSInteger currentPage;
@property (strong, nonatomic) NSDate *referenceDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation RUAMenuTableViewController

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
- (IBAction)changePage:(UIBarButtonItem *)sender
{
    // Preparing to go to previous or next page.
    UITableViewRowAnimation rowAnimation;
    if (sender == self.previousPage) {
        self.currentPage--;
        rowAnimation = UITableViewRowAnimationRight;
        self.referenceDate = [self.referenceDate dateByAddingTimeInterval:-86400];
    } else if (sender == self.nextPage) {
        self.currentPage++;
        rowAnimation = UITableViewRowAnimationLeft;
        self.referenceDate = [self.referenceDate dateByAddingTimeInterval:86400];
    } else {
        // Exit if unknown button pressed.
        return;
    }
    // Performing page change.
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:rowAnimation];
    self.navigationItem.title = [[self.dateFormatter stringFromDate:self.referenceDate] capitalizedStringWithLocale:self.dateFormatter.locale];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    // Disable or enable buttons by current page.
    self.previousPage.enabled = (currentPage > 0);
    self.nextPage.enabled = (currentPage < 6);
    _currentPage = currentPage;
}

#pragma mark - UITableViewController methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // If there is no data source, return 1 to first section (loading row) and 0 to others. Otherwise, return 7 (dishes count).
    if (!self.dataSource) {
        return (section ? 0 : 1);
    }
    return 7;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If there is no data source, return loading cell. Otherwise, return normal cell.
    if (!self.dataSource) {
        return [tableView dequeueReusableCellWithIdentifier:@"Menu Loading Cell" forIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Menu Cell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.textLabel.text = self.menuDishesList[(NSUInteger)indexPath.row];
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.detailTextLabel.text = [self mealMenuForCurrentPageForSection:indexPath.section][(NSUInteger)indexPath.row];
    
    return cell;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set date and date formatter to create appropriate title strings.
    self.referenceDate = [NSDate date];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    self.dateFormatter.doesRelativeDateFormatting = YES;
    self.dateFormatter.locale =  [NSLocale localeWithLocaleIdentifier:[[[NSBundle mainBundle] preferredLocalizations] firstObject]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Get localized dishes list and get menu from server.
    self.menuDishesList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MenuDishesList" ofType:@"plist"]];
    [RUAServerConnection requestMenuForWeekWithCompletionHandler:^(NSArray *weekMenu, NSError *error) {
        // If successful (weekMenu != nil), show menu for the week. Otherwise, show error message.
        if (weekMenu) {
            // Set current page by getting weekday from date components.
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            gregorianCalendar.timeZone = self.dateFormatter.timeZone;
            NSDateComponents *dateComponents = [gregorianCalendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
            self.currentPage = dateComponents.weekday - 2; // Adjusting to 0 based count and monday based weekend.
            
            // Perform updates.
            [self.tableView beginUpdates];
            self.dataSource = weekMenu;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        } else {
            // Get loading cell, hide activity indicator and show an appropriate message.
            RUATableViewLoadingCell *loadingCell = (RUATableViewLoadingCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            loadingCell.infoLabel.text = @"Info Label"; // FIXME: Show appropriate message.
            loadingCell.infoLabel.hidden = NO;
            [loadingCell.activityIndicator stopAnimating];
        }
    }];
}

@end

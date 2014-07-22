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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousPage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextPage;

@property (strong, nonatomic) NSArray *menuDishesList;
@property (strong, nonatomic) NSArray *weekMenu;
@property (assign, nonatomic) NSInteger currentPage;

@end

@implementation RUAMenuTableViewController

- (NSArray *)arrayForSection:(NSInteger)section
{
    return self.weekMenu[(NSUInteger)(self.currentPage * 2 + section)];
}

- (IBAction)changePage:(UIBarButtonItem *)sender
{
    if (sender == self.previousPage) {
        self.currentPage--;
    } else if (sender == self.nextPage) {
        self.currentPage++;
    } else {
        return;
    }
    [self.tableView reloadData];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
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
    return (NSInteger)[self arrayForSection:section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Menu Cell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.textLabel.text = self.menuDishesList[(NSUInteger)indexPath.row];
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.detailTextLabel.text = [self arrayForSection:indexPath.section][(NSUInteger)indexPath.row];
    
    return cell;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure date components with gregorian calendar and São Paulo time zone.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    NSDateComponents *dateComponents = [gregorianCalendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    self.currentPage = dateComponents.weekday - 1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.menuDishesList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MenuDishesList" ofType:@"plist"]];
    [RUAServerConnection requestMenuForWeekWithCompletionHandler:^(NSArray *weekMenu) {
        self.weekMenu = weekMenu;
        [self.tableView reloadData];
    }];
}

@end

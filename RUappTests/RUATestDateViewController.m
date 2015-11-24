//
//  RUATestDateViewController.m
//  RUapp
//
//  Created by Igor Camilo on 2014-08-26.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAAppDelegate.h"
#import "RUAMenuTableViewController.h"
#import "RUAResultsTableViewController.h"
#import "RUAServerConnection.h"
#import "RUATestDateViewController.h"
#import "RUAVoteTableViewController.h"

@implementation RUATestDateViewController

- (IBAction)changeServer:(UISegmentedControl *)sender
{
    [RUAAppDelegate sharedAppDelegate].usesTestServer = (BOOL)sender.selectedSegmentIndex;
}

- (IBAction)cleanCache:(id)sender
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setValue:nil forKey:RUAMenuDataSourceCacheKey];
    [standardUserDefaults setValue:nil forKey:RUAResultsDataSourceCacheKey];
    [standardUserDefaults setValue:nil forKey:RUASavedVotesKey];
    [standardUserDefaults setValue:nil forKey:RUALastVoteDateKey];
}

- (IBAction)datePickerValueChanged:(UIDatePicker *)sender
{
    [RUAAppDelegate sharedAppDelegate].date = sender.date;
}

// MARK: UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSLocale *bundleLocale = [NSLocale localeWithLocaleIdentifier:[[NSBundle mainBundle] preferredLocalizations].firstObject];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    
    self.datePicker.calendar = gregorianCalendar;
    self.datePicker.locale = bundleLocale;
    self.datePicker.timeZone = gregorianCalendar.timeZone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self datePickerValueChanged:self.datePicker];
}

@end

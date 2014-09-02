//
//  RUATestDateViewController.m
//  RUapp
//
//  Created by Igor Camilo on 2014-08-26.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAAppDelegate.h"
#import "RUATestDateViewController.h"

@implementation RUATestDateViewController

- (IBAction)datePickerValueChanged:(UIDatePicker *)sender
{
    [RUAAppDelegate sharedAppDelegate].date = sender.date;
}

// MARK: UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
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

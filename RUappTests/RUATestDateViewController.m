//
//  RUATestDateViewController.m
//  RUapp
//
//  Created by Igor Camilo on 2014-08-26.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUATestDateViewController.h"
#import "RUAAppDelegate.h"

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
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    
    self.datePicker.calendar = gregorianCalendar;
    self.datePicker.timeZone = gregorianCalendar.timeZone;
}

@end

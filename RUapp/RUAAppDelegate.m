//
//  RUAAppDelegate.m
//  RUapp
//
//  Created by Igor Camilo on 19/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAAppDelegate.h"
#import "RUAColor.h"

@implementation RUAAppDelegate

+ (RUAMeal)mealForDate:(NSDate *)date
{
    // Configure date components with gregorian calendar and São Paulo time zone.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    NSDateComponents *dateComponents = [gregorianCalendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    
    // Get hours, minutes and seconds and convert them to a numeric format. Return value according to schedule.
    CGFloat timeNumber = (CGFloat)(dateComponents.hour + dateComponents.minute / 60. + dateComponents.second / 3600.);
    if (timeNumber >= 11 && timeNumber < 16) {
        return RUAMealLunch;
    } else if (timeNumber >= 17 && timeNumber < 21) {
        return RUAMealDinner;
    } else if (timeNumber >= 6.5 && timeNumber < 10) {
        return RUAMealBreakfast;
    }
    return RUAMealNone;
}

+ (RUAMeal)mealForNow
{
    return [self mealForDate:[NSDate date]];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Fix for iOS 7.1.
    self.window.tintColor = [RUAColor lightBlueColor];
    
    return YES;
}

@end

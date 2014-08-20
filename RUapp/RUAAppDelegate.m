//
//  RUAAppDelegate.m
//  RUapp
//
//  Created by Igor Camilo on 19/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAAppDelegate.h"
#import "RUAColor.h"
#import "iRate.h"
#import "RUAServerConnection.h"

@implementation RUAAppDelegate

+ (CGFloat)numberFromTime:(NSDate *)date
{
    // Configure date components with gregorian calendar and São Paulo time zone.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    NSDateComponents *dateComponents = [gregorianCalendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    
    // Get hours and minutes and convert them to a numeric format.
    return (CGFloat)(dateComponents.hour + dateComponents.minute / 60.);
}

+ (RUAMeal)mealForDate:(NSDate *)date
{
    // Return value according to schedule.
    CGFloat timeNumber = [self numberFromTime:date];
    if (timeNumber >= 17 && timeNumber < 21) {
        return RUAMealDinner;
    } else if (timeNumber >= 11 && timeNumber < 16) {
        return RUAMealLunch;
    } else if (timeNumber >= 6.5 && timeNumber < 10) {
        return RUAMealBreakfast;
    }
    return RUAMealNone;
}

+ (RUAMeal)mealForNow
{
    return [self mealForDate:[NSDate date]];
}

+ (RUAMeal)lastMealForDate:(NSDate *__autoreleasing *)date
{
    // Get hours, minutes and seconds and convert them to a numeric format. Return value according to schedule.
    CGFloat timeNumber = [self numberFromTime:*date];
    if (timeNumber >= 17) {
        return RUAMealDinner;
    } else if (timeNumber >= 11) {
        return RUAMealLunch;
    } else if (timeNumber >= 6.5) {
        return RUAMealBreakfast;
    }
    *date = [*date dateByAddingTimeInterval:-86400];
    return RUAMealDinner;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Fix for iOS 7.1.
    self.window.tintColor = [RUAColor lightBlueColor];
    
    // iRate
    [iRate sharedInstance].useAllAvailableLanguages = NO;
//    [iRate sharedInstance].previewMode = YES;
    
    // Background fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [self application:application performFetchWithCompletionHandler:nil];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [RUAServerConnection performFetchWithCompletionHandler:completionHandler];
}

@end

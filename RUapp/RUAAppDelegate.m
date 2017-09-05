//
//  RUAAppDelegate.m
//  RUapp
//
//  Created by Igor Camilo on 19/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "iRate.h"
#import "RUAAppDelegate.h"
#import "RUAColor.h"
#import "RUAServerConnection.h"
#import "GAI.h"

@import Fabric;
@import Crashlytics;

@implementation RUAAppDelegate

// MARK: Methods

+ (RUAMeal)lastMealForDate:(NSDate *__autoreleasing *)date
{
    // Return value according to schedule.
    NSDateComponents *dateComponents = [self dateComponentsForDate:*date];
    CGFloat timeNumber = [self valueFromDateComponents:dateComponents];
    if (timeNumber >= 17) {
        if (dateComponents.weekday >=2 && dateComponents.weekday <= 6) { // From monday to friday
            return RUAMealDinner;
        } else {
            return RUAMealLunch;
        }
    } else if (timeNumber >= 11) {
        return RUAMealLunch;
    } else if (timeNumber >= 6.5 && dateComponents.weekday >=2) { // From monday to saturday
        return RUAMealBreakfast;
    }
    *date = [*date dateByAddingTimeInterval:-86400]; // Less 24 hours
    if (dateComponents.weekday >=3) {
        // From tuesday to saturday
        return RUAMealDinner;
    } else {
        // Sunday and monday
        return RUAMealLunch;
    }
}

+ (RUAMeal)lastMealForNow
{
    NSDate *now = [NSDate date];
    return [self lastMealForDate:&now];
}

+ (RUAMeal)mealForDate:(NSDate *)date
{
    // Return value according to schedule.
    NSDateComponents *dateComponents = [self dateComponentsForDate:date];
    CGFloat timeNumber = [self valueFromDateComponents:dateComponents];
    if (timeNumber >= 17 && timeNumber < 21) {
        if (dateComponents.weekday >=2 && dateComponents.weekday <= 6) { // From monday to friday
            return  RUAMealDinner;
        }
    } else if (timeNumber >= 11 && timeNumber < 16) {
        return RUAMealLunch;
    } else if (timeNumber >= 6.5 && timeNumber < 10) {
        if (dateComponents.weekday >=2) { // From monday to saturday
            return RUAMealBreakfast;
        }
    }
    return RUAMealNone;
}

+ (RUAMeal)mealForNow
{
    return [self mealForDate:[NSDate date]];
}

+ (RUAAppDelegate *)sharedAppDelegate
{
    return [UIApplication sharedApplication].delegate;
}

+ (NSURL *)serverMenuURL
{
    return [NSURL URLWithString:@"http://titugoru3.appspot.com/getvalue"];
}

+ (NSURL *)serverResultsURL
{
    return [NSURL URLWithString:@"http://www.ruapp.com.br/votoresumo.php"];
}

+ (NSURL *)serverVoteURL
{
    return [NSURL URLWithString:@"http://www.ruapp.com.br/votar.php"];
}

// MARK: Helper methods

/**
 * Returns date componens for weekday, hour and minute for Gregorian calendar and Sao Paulo timezone.
 */
+ (NSDateComponents *)dateComponentsForDate:(NSDate *)date
{
    // Configure date components with gregorian calendar and São Paulo time zone.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    return [gregorianCalendar components:NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
}

/**
 * Returns hour and minute as a float.
 */
+ (CGFloat)valueFromDateComponents:(NSDateComponents *)dateComponents
{
    // Get hours and minutes and convert them to a numeric format.
    return (CGFloat)(dateComponents.hour + dateComponents.minute / 60.);
}

// MARK: UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Fix for iOS 7.1.
    self.window.tintColor = [RUAColor lightBlueColor];

    // iRate
    [iRate sharedInstance].useAllAvailableLanguages = NO;
    
    // Google Analytics
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-60467425-1"];
    NSNumber *analyticsValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"AnalyticsEnabled"];
    if (analyticsValue) {
        [GAI sharedInstance].optOut = ![analyticsValue boolValue];
    }
    
    // Fabric
    [Fabric with:@[[Crashlytics class]]];

    // Background fetch
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [self application:application performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {}];

    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [RUAServerConnection performFetchWithCompletionHandler:completionHandler];
}

@end

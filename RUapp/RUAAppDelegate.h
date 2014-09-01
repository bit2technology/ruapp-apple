//
//  RUAAppDelegate.h
//  RUapp
//
//  Created by Igor Camilo on 19/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAMenuTableViewController.h"

typedef NS_ENUM(NSUInteger, RUAMeal) {
    RUAMealLunch,
    RUAMealDinner,
    RUAMealBreakfast,
    RUAMealNone
};

@import UIKit;

@interface RUAAppDelegate : UIResponder <UIApplicationDelegate>

// MARK: Properties

@property (strong, nonatomic) UIWindow *window;

/**
 * Date to use across app. For testing purposes, it is settable. For release, it returns current date.
 */
@property (copy, nonatomic) NSDate *date;

/**
 * Reference to menu view controller, to get menu information.
 */
@property (weak, nonatomic) RUAMenuTableViewController *menuTableViewController;

// MARK: Methods

/**
 * Last meal for date. Date will return one day earlier if it's before breakfast.
 */
+ (RUAMeal)lastMealForDate:(NSDate *__autoreleasing *)date;

/**
 * Last meal for now.
 */
+ (RUAMeal)lastMealForNow;

/**
 * Meal for a given time.
 */
+ (RUAMeal)mealForDate:(NSDate *)date;

/**
 * Meal for now.
 */
+ (RUAMeal)mealForNow;

/**
 * Returns app delegate instance.
 */
+ (RUAAppDelegate *)sharedAppDelegate;

@end

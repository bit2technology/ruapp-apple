//
//  RUAAppDelegate.h
//  RUapp
//
//  Created by Igor Camilo on 19/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAEnums.h"
#import "RUAMenuTableViewController.h"

@import UIKit;

@interface RUAAppDelegate : UIResponder <UIApplicationDelegate>

// MARK: Properties

/**
 * Reference to menu view controller, to get menu information.
 */
@property (weak, nonatomic) RUAMenuTableViewController *menuTableViewController;

/**
 * Defines if the app uses the test server.
 */
@property (assign, nonatomic) BOOL usesTestServer;

@property (strong, nonatomic) UIWindow *window;

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
 * Returns the official server URL.
 */
+ (NSURL *)serverMenuURL;

/**
 * Returns the results URL.
 */
+ (NSURL *)serverResultsURL;

/**
 * Returns the vote URL.
 */
+ (NSURL *)serverVoteURL;

/**
 * Returns app delegate instance.
 */
+ (RUAAppDelegate *)sharedAppDelegate;

@end

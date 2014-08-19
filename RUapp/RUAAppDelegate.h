//
//  RUAAppDelegate.h
//  RUapp
//
//  Created by Igor Camilo on 19/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

typedef NS_ENUM(NSUInteger, RUAMeal) {
    RUAMealLunch,
    RUAMealDinner,
    RUAMealBreakfast,
    RUAMealNone
};

@import UIKit;

@interface RUAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 * Meal for a given time.
 */
+ (RUAMeal)mealForDate:(NSDate *)date;

/**
 * Meal for now.
 */
+ (RUAMeal)mealForNow;

+ (RUAMeal)lastMealForDate:(NSDate *__autoreleasing *)date;

@end

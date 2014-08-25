//
//  RUAServerConnection.h
//  RUapp
//
//  Created by Igor Camilo on 18/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAAppDelegate.h"

@import UIKit;

typedef NS_ENUM(NSUInteger, RUARestaurant) {
    RUARestaurantJuizDeForaDowntown,
    RUARestaurantJuizDeForaCampus,
    RUARestaurantNone
};

typedef NS_ENUM(NSUInteger, RUARating) {
    RUARatingVeryGood,
    RUARatingGood,
    RUARatingBad,
    RUARatingVeryBad,
    RUARatingNone
};

typedef NS_ENUM(NSUInteger, RUADish) {
    RUADishMain,
    RUADishVegetarian,
    RUADishGarnish,
    RUADishPasta,
    RUADishSide,
    RUADishSalad,
    RUADishDessert,
    RUADishTotal,
    RUADishNone
};

@interface RUAResultInfo : NSObject

@property (assign, nonatomic) RUARestaurant restaurant;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) RUAMeal meal;
@property (assign, nonatomic) NSUInteger votesTotal;
@property (strong, nonatomic) NSArray *votesText;
@property (strong, nonatomic) NSArray *votesProgress;
@property (strong, nonatomic) NSArray *reasons;

@end

@interface RUAServerConnection : NSObject

/**
 * Send vote for current meal.
 */
+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant rating:(RUARating)vote reason:(NSArray *)reason completionHandler:(void (^)(NSDate *voteDate, NSString *localizedMessage))handler;

/**
 * Request vote results.
 */
+ (void)requestResultsWithCompletionHandler:(void (^)(NSArray *results, NSError *error))handler;

/**
 * Get week menu for current week.
 */
+ (void)requestMenuForWeekWithCompletionHandler:(void (^)(NSArray *weekMenu, NSError *error))handler;

/**
 * Send saved votes to server.
 */
+ (void)performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end

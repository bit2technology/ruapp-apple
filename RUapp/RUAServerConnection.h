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
    RUAVoteVeryGood,
    RUAVoteGood,
    RUAVoteBad,
    RUAVoteVeryBad,
    RUAVoteNone
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

@property (readonly, nonatomic) RUARestaurant restaurant;
@property (readonly, nonatomic) NSDate *date;
@property (readonly, nonatomic) RUAMeal meal;
@property (readonly, nonatomic) NSArray *votesText;
@property (readonly, nonatomic) NSArray *votesProgress;
@property (readonly, nonatomic) NSArray *reasons;


@end

@interface RUAServerConnection : NSObject

/**
 * Send vote for current meal.
 */
+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant vote:(RUARating)vote reason:(NSArray *)reason completionHandler:(void (^)(NSDate *voteDate, NSError *error))handler;

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

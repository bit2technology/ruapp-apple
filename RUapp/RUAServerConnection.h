//
//  RUAServerConnection.h
//  RUapp
//
//  Created by Igor Camilo on 18/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

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

@interface RUAServerConnection : NSObject

/**
 * Send vote for current meal.
 */
+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant vote:(RUARating)vote reason:(NSArray *)reason completionHandler:(void (^)(NSDate *voteDate, NSError *error))handler;

+ (void)requestResultsWithDate:(NSDate *)date completionHandler:(void (^)(NSDictionary *results, NSError *error))handler;

/**
 * Get week menu for current week.
 */
+ (void)requestMenuForWeekWithCompletionHandler:(void (^)(NSArray *weekMenu))handler;

@end

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
    RUARestaurantJuizDeForaCampus
};

typedef NS_ENUM(NSUInteger, RUARating) {
    RUAVoteVeryGood,
    RUAVoteGood,
    RUAVoteBad,
    RUAVoteVeryBad
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
+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant vote:(RUARating)vote reason:(RUADish *)reason completionHandler:(void (^)(void))handler;

/**
 * Get week menu for current week.
 */
+ (void)requestMenuForWeekWithCompletionHandler:(void (^)(NSArray *weekMenu))handler;

@end

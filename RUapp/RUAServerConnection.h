//
//  RUAServerConnection.h
//  RUapp
//
//  Created by Igor Camilo on 18/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, RUARestaurant) {
    RUARestaurantJuizDeForaCampus,
    RUARestaurantJuizDeForaDowntown
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
    RUADishDessert
};

@interface RUAServerConnection : NSObject

+ (void)sendVoteWithRestaurant:(RUARestaurant)restaurant date:(NSDate *)date vote:(RUARating)vote reason:(RUADish[])reason completionHandler:(void (^)(void))handler;

@end

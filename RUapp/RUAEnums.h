//
//  RUAEnums.h
//  RUapp
//
//  Created by Igor Camilo on 05/09/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#ifndef RUapp_RUAEnums_h
#define RUapp_RUAEnums_h

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

typedef NS_ENUM(NSUInteger, RUAMeal) {
    RUAMealBreakfast,
    RUAMealLunch,
    RUAMealDinner,
    RUAMealNone
};

typedef NS_ENUM(NSUInteger, RUARating) {
    RUARatingVeryGood,
    RUARatingGood,
    RUARatingBad,
    RUARatingVeryBad,
    RUARatingNone
};

typedef NS_ENUM(NSUInteger, RUARestaurant) {
    RUARestaurantJuizDeForaDowntown,
    RUARestaurantJuizDeForaCampus,
    RUARestaurantNone
};

#endif

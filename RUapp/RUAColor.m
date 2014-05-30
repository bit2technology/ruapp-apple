//
//  RUAColor.m
//  RUapp
//
//  Created by Igor Camilo on 20/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAColor.h"

@implementation RUAColor

+ (UIColor *)lightBlueColor
{
    return [UIColor colorWithRed:(CGFloat).235294117647058820264049927573068998754024505615234375 green:(CGFloat).71372549019607844922319372926722280681133270263671875 blue:(CGFloat).890196078431372495032292135874740779399871826171875 alpha:1]; // rgb(60, 182, 227).
}

+ (UIColor *)darkBlueColor
{
    return [UIColor colorWithRed:(CGFloat).1294117647058823650230152679796447046101093292236328125 green:(CGFloat).137254901960784325698483598898747004568576812744140625 blue:(CGFloat).3098039215686274605587868791189976036548614501953125 alpha:1]; // rgb(33, 35, 79).
}

+ (UIColor *)darkerBlueColor
{
    // TODO: Use constants.
    return [UIColor colorWithRed:(CGFloat)(27./255.) green:(CGFloat)(27./255.) blue:(CGFloat)(49./255.) alpha:1];
}

@end

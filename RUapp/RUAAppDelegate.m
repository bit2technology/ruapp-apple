//
//  RUAAppDelegate.m
//  RUapp
//
//  Created by Igor Camilo on 19/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAAppDelegate.h"

#import "RUAColor.h"

@implementation RUAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set tab bar's tint color properly on iOS 7 and 6.
    [(UITabBarController *)self.window.rootViewController tabBar].tintColor = (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 ? [RUAColor lightBlueColor] : nil);
    
    return YES;
}

@end

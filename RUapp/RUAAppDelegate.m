//
//  RUAAppDelegate.m
//  RUapp
//
//  Created by Igor Camilo on 19/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAAppDelegate.h"

@implementation RUAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        [(UITabBarController *)self.window.rootViewController tabBar].tintColor = nil;
    }
    
    return YES;
}

@end

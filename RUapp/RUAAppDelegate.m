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
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    // Set properties by iOS version.
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7 and later.
        self.window.tintColor = [RUAColor lightBlueColor];
        tabBarController.tabBar.barStyle = UIBarStyleBlack;
    } else {
        // iOS 6 and earlier.
        tabBarController.tabBar.selectedImageTintColor = [RUAColor lightBlueColor];
    }
    
    return YES;
}

@end

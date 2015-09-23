//
//  AppDelegate.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

let DeviceIsPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Appearance
        window?.tintColor = UIColor.appLightBlue()
        let navBar = UINavigationBar.appearance()
        navBar.barStyle = .Black
        navBar.barTintColor = UIColor.appDarkBlue()
        navBar.translucent = false
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Dosis-SemiBold", size: 20)!]
        let tabBar = UITabBar.appearance()
        tabBar.barStyle = .Black
        tabBar.barTintColor = UIColor.appDarkBlue()
        tabBar.translucent = false
        
        return true
    }
}


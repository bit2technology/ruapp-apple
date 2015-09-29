//
//  AppDelegate.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit

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
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.appNavTitle()]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem()], forState: .Normal)
        let tabBar = UITabBar.appearance()
        tabBar.barStyle = .Black
        tabBar.barTintColor = UIColor.appDarkBlue()
        tabBar.translucent = false      
        
        return true
    }
}

extension UIFont {
    
    class func appBarItem() -> UIFont {
        return UIFont(name: "Dosis-SemiBold", size: 18)!
    }
    
    class func appBarItemDone() -> UIFont {
        return UIFont(name: "Dosis-Bold", size: 18)!
    }
    
    class func appNavTitle() -> UIFont {
        return UIFont(name: "Dosis-SemiBold", size: 20)!
    }
}

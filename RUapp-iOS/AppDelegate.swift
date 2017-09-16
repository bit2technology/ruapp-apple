//
//  AppDelegate.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        applyAppaerance()
        return true
    }
    
    private func applyAppaerance() {
        UIFont.appRegisterFonts()
        window?.tintColor = .appLightBlue
        let navBar = UINavigationBar.appearance()
        navBar.barStyle = .black
        navBar.barTintColor = .appDarkBlue
        navBar.isTranslucent = false
        navBar.titleTextAttributes = [.font: UIFont.appNavTitle]
        if #available(iOS 11.0, *) {
            navBar.largeTitleTextAttributes = [.font: UIFont.appLargeNavTitle]
        }
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.appBarItem], for: .normal)
        let tabBar = UITabBar.appearance()
        tabBar.barStyle = .black
        tabBar.barTintColor = .appDarkBlue
        tabBar.isTranslucent = false
        UIAlertView.appearance().tintColor = .red
    }
}

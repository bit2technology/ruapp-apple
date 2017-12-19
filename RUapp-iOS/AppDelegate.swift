//
//  AppDelegate.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import RUappShared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        configure(app: application)
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        applyAppaerance()
        return true
    }
    
    private func applyAppaerance() {
        UIFont.appRegisterFonts()
        window?.tintColor = .appLighterBlue
        let navBar = UINavigationBar.appearance()
        navBar.barStyle = .black
        navBar.barTintColor = .appDarkBlue
//        navBar.isTranslucent = false
//        navBar.titleTextAttributes = [.font: UIFont.appNavTitle]
        if #available(iOS 11.0, *) {
//            navBar.largeTitleTextAttributes = [.font: UIFont.appLargeNavTitle]
        }
//        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.appBarItem], for: .normal)
        let tabBar = UITabBar.appearance()
        tabBar.barStyle = .black
        tabBar.barTintColor = .appDarkBlue
        tabBar.tintColor = .white
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = .appLighterBlue
//            UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont.appTabBarItemTitle], for: .normal)
        } else {
            (window?.rootViewController as! UITabBarController).tabBar.items?.forEach { (item) in
                item.image = item.image?.with(color: .appLighterBlue).withRenderingMode(.alwaysOriginal)
                item.setTitleTextAttributes([.foregroundColor: UIColor.appLighterBlue], for: .normal)
                item.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            }
        }
//        tabBar.isTranslucent = false
    }
}

extension UIImage {
    func with(color: UIColor) -> UIImage {
        guard let cgImage = self.cgImage else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: imageRect, mask: cgImage)
        color.setFill()
        context.fill(imageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

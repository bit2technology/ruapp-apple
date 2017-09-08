//
//  AppDelegate.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Appearance
        window?.tintColor = .appLightBlue
        let navBar = UINavigationBar.appearance()
        navBar.barStyle = .black
        navBar.barTintColor = .appDarkBlue
        navBar.isTranslucent = false
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.appNavTitle()]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem()], for: .normal)
        let tabBar = UITabBar.appearance()
        tabBar.barStyle = .black
        tabBar.barTintColor = .appDarkBlue
        tabBar.isTranslucent = false      
        
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

extension UIImage {
    
    class func circle(diameter: CGFloat, color: UIColor, insets: UIEdgeInsets = .zero) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: insets.left + diameter + insets.right, height: insets.top + diameter + insets.bottom), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fillEllipse(in: CGRect(x: insets.left, y: insets.top, width: diameter, height: diameter))
        let circleImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return circleImg!
    }
    
    class func roundedRect(radius: CGFloat, color: UIColor, insets: UIEdgeInsets = .zero) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: radius * 2 + insets.left + 1 + insets.right, height: radius * 2 + insets.top + 1 + insets.bottom), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.addPath(UIBezierPath(roundedRect: CGRect(x: insets.left, y: insets.top, width: radius * 2 + 1, height: radius * 2 + 1), cornerRadius: radius).cgPath)
        ctx?.fillPath()
        let rectImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectImg!.resizableImage(withCapInsets: UIEdgeInsets(top: insets.top + radius, left: insets.left + radius, bottom: insets.bottom + radius, right: insets.right + radius))
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            if newValue > 0 {
                layer.cornerRadius = newValue
                layer.masksToBounds = true
                layer.rasterizationScale = UIScreen.main.scale
                layer.shouldRasterize = true
            } else {
                layer.cornerRadius = 0
                layer.masksToBounds = false
                layer.shouldRasterize = false
            }
        }
    }
}

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

public extension UIColor {
    
    class func appDarkBlue() -> UIColor {
        return UIColor(red:0.01, green:0.47, blue:0.74, alpha:1.0)
    }
    
    class func appBlue() -> UIColor {
        return UIColor(red:0.01, green:0.66, blue:0.96, alpha:1.0)
    }
    
    class func appLightBlue() -> UIColor {
        return UIColor(red:0.31, green:0.76, blue:0.97, alpha:1.0)
    }
    
    class func appOrange() -> UIColor {
        return UIColor(red:1.00, green:0.55, blue:0.00, alpha:1.0)
    }
    
    class func appMeatRed() -> UIColor {
        return UIColor(red:0.79, green:0.31, blue:0.37, alpha:1.0)
    }
    
    class func appVegetarianGreen() -> UIColor {
        return UIColor(red:0.41, green:0.73, blue:0.26, alpha:1.0)
    }
    
    class func appError() -> UIColor {
        return UIColor.redColor()
    }
}

extension UIFont {
    
    class func appBarItem() -> UIFont {
        return UIFont(name: "Dosis-SemiBold", size: 18)!
    }
    
    class func appBarItemDone() -> UIFont {
        return UIFont(name: "Dosis-Bold", size: 18)!
    }
    
    class func appMenuDish() -> UIFont {
        return UIFont(name: "Dosis-Book", size: 15)!
    }
    
    class func appMenuDishTitle() -> UIFont {
        return UIFont(name: "Dosis-Book", size: 14)!
    }
    
    class func appNavTitle() -> UIFont {
        return UIFont(name: "Dosis-SemiBold", size: 20)!
    }
}

extension UIImage {
    
    class func circle(diameter: CGFloat, color: UIColor, insets: UIEdgeInsets = UIEdgeInsetsZero) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: insets.left + diameter + insets.right, height: insets.top + diameter + insets.bottom), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextFillEllipseInRect(ctx, CGRect(x: insets.left, y: insets.top, width: diameter, height: diameter))
        let circleImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return circleImg
    }
    
    class func roundedRect(radius: CGFloat, color: UIColor, insets: UIEdgeInsets = UIEdgeInsetsZero) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: radius * 2 + insets.left + 1 + insets.right, height: radius * 2 + insets.top + 1 + insets.bottom), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextAddPath(ctx, UIBezierPath(roundedRect: CGRect(x: insets.left, y: insets.top, width: radius * 2 + 1, height: radius * 2 + 1), cornerRadius: radius).CGPath)
        CGContextFillPath(ctx)
        let rectImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectImg.resizableImageWithCapInsets(UIEdgeInsets(top: insets.top + radius, left: insets.left + radius, bottom: insets.bottom + radius, right: insets.right + radius))
    }
}
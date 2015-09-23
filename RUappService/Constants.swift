//
//  Constants.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public enum RUappServiceError: ErrorType {
    case InvalidObject
    case Unknown
}

public let globalUserDefaults = NSUserDefaults(suiteName: "group.com.bit2software.RUapp")

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
//
//  AppDelegate.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 01/10/18.
//

import UIKit
import RUappCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(Hello.test)
        return true
    }
}

//
//  AppDelegate.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 01/03/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit
import RUappShared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    applyAppaerance()
    PersistentContainer.shared.loadPersistentStore()
      .done(on: .main) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.window?.rootViewController = mainStoryboard.instantiateInitialViewController()
        self.applyLegacyAppearance()
      }
      .catch { fatalError("Core Data stack error: \($0.localizedDescription)") }

    return true
  }

  private func applyAppaerance() {
    window?.tintColor = .appLighterBlue
    let navBar = UINavigationBar.appearance()
    navBar.barStyle = .black
    navBar.barTintColor = .appDarkBlue
    let tabBar = UITabBar.appearance()
    tabBar.barStyle = .black
    tabBar.barTintColor = .appDarkBlue
    tabBar.tintColor = .white
    if #available(iOS 10.0, *) {
      tabBar.unselectedItemTintColor = .appLighterBlue
    }
  }

  private func applyLegacyAppearance() {
    guard #available(iOS 10.0, *) else {
      (window?.rootViewController as! UITabBarController).tabBar.items?.forEach { (item) in
        item.image = item.image?.with(color: .appLighterBlue).withRenderingMode(.alwaysOriginal)
        item.setTitleTextAttributes([.foregroundColor: UIColor.appLighterBlue], for: .normal)
        item.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
      }
      return
    }
  }
}

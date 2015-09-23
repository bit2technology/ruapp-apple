//
//  MainController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit

class MainController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "Tab Bar Controller"?:
            guard let tabCont = segue.destinationViewController as? UITabBarController else {
                break
            }
            tabCont.delegate = self
            titleLabel.text = tabCont.viewControllers?.first?.tabBarItem.title?.uppercaseString
        case "Sidebar"?:
            guard let popover = segue.destinationViewController.popoverPresentationController,
                forkBtn = sender as? UIButton else {
                break
            }
            popover.sourceRect = forkBtn.bounds
            popover.backgroundColor = UIColor.appDarkBlue()
        default:
            break
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textAttrs = UINavigationBar.appearance().titleTextAttributes
        titleLabel.font = textAttrs?[NSFontAttributeName] as? UIFont
        titleLabel.textColor = textAttrs?[NSForegroundColorAttributeName] as? UIColor
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        titleLabel.text = viewController.tabBarItem.title?.uppercaseString
    }
}

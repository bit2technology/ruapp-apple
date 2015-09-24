//
//  MainController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

class MainController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cafeteriaBtn: UIButton!
    
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
        
        titleLabel.font = UIFont.appNavTitle()
        titleLabel.textColor = UIColor.whiteColor()
        cafeteriaBtn.titleLabel?.font = UIFont.appBarItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        if Institution.shared() == nil {
            performSegueWithIdentifier("Register Student", sender: nil)
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        titleLabel.text = viewController.tabBarItem.title?.uppercaseString
    }
}

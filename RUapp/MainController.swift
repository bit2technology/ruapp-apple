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
    
    @IBOutlet weak var menuTypeSelector: MenuTypeSelector!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cafeteriaBtn: UIButton!
    
    private weak var sidebarCont: SidebarController?
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        
    }
    
//    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
//        print(identifier)
//        return true
//        guard Institution.shared() == nil && Student.shared() == nil else {
//            let alert = UIAlertController(title: "This software is still in beta", message: "Sorry, you still can't edit this information yet", preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            presentViewController(alert, animated: true, completion: nil)
//            break
//        }
//
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "Tab Bar Controller"?:
            guard let tabCont = segue.destinationViewController as? UITabBarController,
                viewConts = tabCont.viewControllers else {
                break
            }
            let imgVerInset: CGFloat = 5.5
            for viewCont in viewConts {
                let tabItem = viewCont.tabBarItem
                tabItem.titlePositionAdjustment.vertical = 9999
                tabItem.imageInsets = UIEdgeInsets(top: imgVerInset, left: 0, bottom: -imgVerInset, right: 0)
            }
            tabCont.delegate = self
            titleLabel.text = tabCont.viewControllers?.first?.tabBarItem.title?.uppercaseString
        case "Main To Sidebar"?:
            guard let sidebar = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? SidebarController,
                popover = segue.destinationViewController.popoverPresentationController,
                forkBtn = sender as? UIButton else {
                break
            }
            sidebarCont = sidebar
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
        if Institution.shared() == nil || Student.shared() == nil {
            performSegueWithIdentifier("Main To Registration", sender: nil)
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        sidebarCont?.traitCollectionDidChange(previousTraitCollection)
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        titleLabel.text = viewController.tabBarItem.title?.uppercaseString
    }
}

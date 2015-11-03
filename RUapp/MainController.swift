//
//  MainController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

private var globalMainController: MainController?

class MainController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak var menuTypeSelector: MenuTypeSelector!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cafeteriaBtn: UIButton!
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    
    private weak var sidebarCont: SidebarController?
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "Tab Bar Controller"?:
            guard let tabCont = segue.destinationViewController as? UITabBarController,
                viewConts = tabCont.viewControllers else {
                break
            }
            let imgVerInset: CGFloat
            if #available(iOS 9.0, *) {
                imgVerInset = traitCollection.userInterfaceIdiom == .Pad ? 8 : 5.5
            } else {
                imgVerInset = traitCollection.userInterfaceIdiom == .Pad ? 5 : 5.5
            }
            for viewCont in viewConts {
                let tabItem = viewCont.tabBarItem
                tabItem.titlePositionAdjustment.vertical = 9999
                tabItem.imageInsets = UIEdgeInsets(top: imgVerInset, left: 0, bottom: -imgVerInset, right: 0)
            }
            tabCont.delegate = self
            titleLabel.text = tabCont.viewControllers?.first?.tabBarItem.title?.uppercaseString
        case "Main To Sidebar"?:
            guard let sidebar = segue.destinationViewController as? SidebarController,
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
        
        globalMainController = self
        
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
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        if viewController.needsMenuTypeSelector() {
            menuTypeSelector.hidden = false
            topBarHeight.constant = traitCollection.horizontalSizeClass == .Regular ? 64 : 108
        } else {
            menuTypeSelector.hidden = true
            topBarHeight.constant = 64
        }
        
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        titleLabel.text = viewController.tabBarItem.title?.uppercaseString
    }
}

extension UIViewController {
    
    var mainController: MainController {
        return globalMainController!
    }
    
    func needsMenuTypeSelector() -> Bool {
        return false
    }
}

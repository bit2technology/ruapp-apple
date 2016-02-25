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
    @IBOutlet weak var restaurantBtn: UIButton!
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    
    private weak var sidebarCont: SidebarController?
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        
    }
    
    @objc private func menuTypeSelectorValueChanged(sender: MenuTypeSelector) {
        Menu.defaultKind = Menu.Kind(rawValue: sender.selectedSegmentIndex) ?? .Traditional
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case "Main To Restaurants":
            return Institution.shared?.campi != nil
        default:
            return true
        }
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
        restaurantBtn.titleLabel?.font = UIFont.appBarItem()
        
        menuTypeSelector.selectedSegmentIndex = Menu.defaultKind.rawValue
        menuTypeSelector.addTarget(self, action: #selector(MainController.menuTypeSelectorValueChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var restaurantBtnTitle = Restaurant.userDefault?.name ?? NSLocalizedString("MainController.restaurantBtn.title", value: "restaurant", comment: "Title of button to choose a default restaurant")
        if #available(iOS 9.0, *) {
            restaurantBtnTitle = restaurantBtnTitle.localizedLowercaseString
        } else {
            restaurantBtnTitle = restaurantBtnTitle.lowercaseString
        }
        
        restaurantBtn.setTitle(restaurantBtnTitle, forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        if Institution.shared == nil || Student.shared == nil {
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
        if #available(iOS 9.0, *) {
            titleLabel.text = viewController.tabBarItem.title?.localizedUppercaseString
        } else {
            titleLabel.text = viewController.tabBarItem.title?.uppercaseString
        }
    }
}

class SelectDefaultRestaurantController: UITableViewController {
    
    private let campi = Institution.shared?.campi ?? []
    private var selected = Restaurant.userDefault
    private let btnClose = UIBarButtonItem(image: UIImage(named: "BtnClose"), style: .Plain, target: nil, action: nil)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        btnClose.target = self
        btnClose.action = #selector(SelectDefaultRestaurantController.cancelTap)
        btnClose.imageInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
    }
    
    @IBAction func cancelTap() {
        performSegueWithIdentifier("Restaurants To Main", sender: nil)
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if presentingViewController?.traitCollection.horizontalSizeClass == .Regular {
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = btnClose
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationItem.title?.uppercaseString
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return campi.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campi[section].restaurants.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return campi[section].name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Restaurant Cell", forIndexPath: indexPath)
        let rest = campi[indexPath.section].restaurants[indexPath.row]
        
        cell.textLabel?.text = rest.name
        cell.accessoryType = rest.id == selected?.id ? .Checkmark : .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Restaurant.userDefault = campi[indexPath.section].restaurants[indexPath.row]
        performSegueWithIdentifier("Restaurants To Main", sender: nil)
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

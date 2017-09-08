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
    
    fileprivate weak var sidebarCont: SidebarController?
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {
        
    }
    
    @objc fileprivate func menuTypeSelectorValueChanged(_ sender: MenuTypeSelector) {
        Menu.defaultKind = Menu.Kind(rawValue: sender.selectedSegmentIndex) ?? .traditional
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "Main To Restaurants":
            return Institution.shared?.campi != nil
        default:
            return true
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Tab Bar Controller"?:
            guard let tabCont = segue.destination as? UITabBarController,
                let viewConts = tabCont.viewControllers else {
                break
            }
            let imgVerInset: CGFloat
            if #available(iOS 9.0, *) {
                imgVerInset = traitCollection.userInterfaceIdiom == .pad ? 8 : 5.5
            } else {
                imgVerInset = traitCollection.userInterfaceIdiom == .pad ? 5 : 5.5
            }
            for viewCont in viewConts {
                let tabItem = viewCont.tabBarItem
                tabItem?.titlePositionAdjustment.vertical = 9999
                tabItem?.imageInsets = UIEdgeInsets(top: imgVerInset, left: 0, bottom: -imgVerInset, right: 0)
            }
            tabCont.delegate = self
            titleLabel.text = tabCont.viewControllers?.first?.tabBarItem.title?.uppercased()
        case "Main To Sidebar"?:
            guard let sidebar = segue.destination as? SidebarController,
                let popover = segue.destination.popoverPresentationController,
                let forkBtn = sender as? UIButton else {
                break
            }
            sidebarCont = sidebar
            popover.sourceRect = forkBtn.bounds
            popover.backgroundColor = .appDarkBlue
        default:
            break
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        globalMainController = self
        
        titleLabel.font = UIFont.appNavTitle()
        titleLabel.textColor = UIColor.white
        restaurantBtn.titleLabel?.font = UIFont.appBarItem()
        
        menuTypeSelector.selectedSegmentIndex = Menu.defaultKind.rawValue
        menuTypeSelector.addTarget(self, action: #selector(MainController.menuTypeSelectorValueChanged(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var restaurantBtnTitle = Restaurant.userDefault?.name ?? NSLocalizedString("MainController.restaurantBtn.title", value: "restaurant", comment: "Title of button to choose a default restaurant")
        if #available(iOS 9.0, *) {
            restaurantBtnTitle = restaurantBtnTitle.localizedLowercase
        } else {
            restaurantBtnTitle = restaurantBtnTitle.lowercased()
        }
        
        restaurantBtn.setTitle(restaurantBtnTitle, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Institution.shared == nil || Student.shared == nil {
            performSegue(withIdentifier: "Main To Registration", sender: nil)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        sidebarCont?.traitCollectionDidChange(previousTraitCollection)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController.needsMenuTypeSelector() {
            menuTypeSelector.isHidden = false
            topBarHeight.constant = traitCollection.horizontalSizeClass == .regular ? 64 : 108
        } else {
            menuTypeSelector.isHidden = true
            topBarHeight.constant = 64
        }
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if #available(iOS 9.0, *) {
            titleLabel.text = viewController.tabBarItem.title?.localizedUppercase
        } else {
            titleLabel.text = viewController.tabBarItem.title?.uppercased()
        }
    }
}

class SelectDefaultRestaurantController: UITableViewController {
    
    fileprivate let campi = Institution.shared?.campi ?? []
    fileprivate var selected = Restaurant.userDefault
    fileprivate let btnClose = UIBarButtonItem(image: #imageLiteral(resourceName: "BtnClose"), style: .plain, target: nil, action: nil)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        btnClose.target = self
        btnClose.action = #selector(SelectDefaultRestaurantController.cancelTap)
        btnClose.imageInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
    }
    
    @IBAction func cancelTap() {
        performSegue(withIdentifier: "Restaurants To Main", sender: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if presentingViewController?.traitCollection.horizontalSizeClass == .regular {
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = btnClose
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationItem.title?.uppercased()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return campi.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campi[section].restaurants.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return campi[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Restaurant Cell", for: indexPath)
        let rest = campi[indexPath.section].restaurants[indexPath.row]
        
        cell.textLabel?.text = rest.name
        cell.accessoryType = rest.id == selected?.id ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Restaurant.userDefault = campi[indexPath.section].restaurants[indexPath.row]
        performSegue(withIdentifier: "Restaurants To Main", sender: nil)
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

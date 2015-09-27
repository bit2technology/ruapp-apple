//
//  SidebarController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

class SidebarController: UITableViewController {
    
    @IBAction func doneTap() {
        performSegueWithIdentifier("Sidebar To Main", sender: nil)
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        navigationController?.navigationBarHidden = presentingViewController?.traitCollection.horizontalSizeClass == .Regular
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = nil
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItemDone()], forState: .Normal)
        
        let blueTop = UIView(frame: CGRect(x: 0, y: -9999, width: 9999, height: 9999))
        blueTop.backgroundColor = UIColor.appDarkBlue()
        view.addSubview(blueTop)
    }
    
    private let scale = UIScreen.mainScreen().scale
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1 / scale
    }
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let superview = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        let separator = UIView(frame: CGRect(x: 15, y: 0, width: 85, height: 10))
        separator.backgroundColor = tableView.separatorColor
        separator.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        superview.addSubview(separator)
        return superview
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            performSegueWithIdentifier("Sidebar To Registration", sender: nil)
        case (1, 2): // Configuration
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        default:
            break
        }
    }
}

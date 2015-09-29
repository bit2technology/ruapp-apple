//
//  SidebarController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

class SidebarController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var closeBtn: UIButton!
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        closeBtn.hidden = presentingViewController?.traitCollection.horizontalSizeClass == .Regular
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

class SidebarTableController: UITableViewController {
    
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
            guard Institution.shared() == nil && Student.shared() == nil else {
                let alert = UIAlertController(title: "This software is still in beta", message: "Sorry, you still can't edit this information yet", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                break
            }
            performSegueWithIdentifier("Sidebar To Registration", sender: nil)
        case (1, 2): // Configuration
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        default:
            break
        }
    }
}
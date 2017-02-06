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
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        closeBtn.isHidden = presentingViewController?.traitCollection.horizontalSizeClass == .regular
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

class SidebarTableController: UITableViewController {
    
    @IBOutlet weak var studentNameCell: UITableViewCell!
    @IBOutlet weak var insitutionCell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        studentNameCell.textLabel?.text = Student.shared?.name
        insitutionCell.textLabel?.text = Institution.shared?.name
    }
    
    fileprivate let scale = UIScreen.main.scale
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1 / scale
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let superview = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        let separator = UIView(frame: CGRect(x: 15, y: 0, width: 85, height: 10))
        separator.backgroundColor = tableView.separatorColor
        separator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        superview.addSubview(separator)
        return superview
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            performSegue(withIdentifier: "Sidebar To Registration", sender: nil)
        case (1, 2): // Configuration
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        default:
            break
        }
    }
}

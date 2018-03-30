//
//  EditStudentController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 28/03/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit

class EditStudentController: UITableViewController {

  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    if let header = view as? UITableViewHeaderFooterView {
      header.textLabel?.textColor = .appLighterBlue
    }
  }
}

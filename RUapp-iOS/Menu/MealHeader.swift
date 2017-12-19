//
//  MealHeader.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 19/12/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import UIKit

class MealHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.textColor = .white
        }
    }
    
    func applyLayout() {
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        layoutIfNeeded()
    }
}

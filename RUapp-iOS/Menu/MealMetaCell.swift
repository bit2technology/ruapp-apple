//
//  MealMetaCell.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 11/01/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit

class MealMetaCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    
    func applyLayout() {
        
        let font = UIFont.preferredFont(forTextStyle: .body)
        
        name.font = font
        message.font = font
        
        layoutIfNeeded()
    }
}

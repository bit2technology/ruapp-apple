//
//  MenuCell.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-25.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit

class MenuCell: UICollectionViewCell {
    
    @IBOutlet var backgroundImg: UIImageView!
    @IBOutlet var mealLabel: UILabel!
    @IBOutlet var dayOfWeekLabel: UILabel!
    
    
    
    private var items = [MenuCellDish]()
}

class MenuCellDish: UIView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    class func instantiate() -> MenuCellDish {
        return NSBundle.mainBundle().loadNibNamed("MenuCellDish", owner: nil, options: nil).first as! MenuCellDish
    }
}
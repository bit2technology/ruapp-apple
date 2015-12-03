//
//  MenuCell.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-25.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

class MenuCell: UICollectionViewCell {
    
    @IBOutlet var backgroundImg: UIImageView!
    @IBOutlet var mealLabel: UILabel!
    @IBOutlet var dayOfWeekLabel: UILabel!
    @IBOutlet var dishesWrapper: UIView!
    var dishes: [MenuCellDish] {
        return dishesWrapper.subviews as! [MenuCellDish]
    }
    var numberOfDishes: Int = 0 {
        didSet {
            // Clear dishes text
            for dishView in dishes {
                dishView.titleLabel.text = nil
                dishView.nameLabel.text = nil
            }
            // Add more dishes if necessary
            if dishes.count < numberOfDishes {
                for i in dishes.count..<numberOfDishes {
                    let newDishView = MenuCellDish.instantiate()
                    var viewsDict = ["newDishView": newDishView]
                    let verticalConstraintFormat: String
                    if i > 0 {
                        verticalConstraintFormat = "V:[lastDishView][newDishView]"
                        viewsDict["lastDishView"] = dishes.last!
                    } else {
                        verticalConstraintFormat = "V:|[newDishView]"
                    }
                    newDishView.backgroundColor = nil
                    newDishView.translatesAutoresizingMaskIntoConstraints = false
                    dishesWrapper.addSubview(newDishView)
                    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[newDishView]|", options: [], metrics: nil, views: viewsDict))
                    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(verticalConstraintFormat, options: [], metrics: nil, views: viewsDict))
                }
            }
        }
    }
}

class MenuCellDish: UIView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    class func instantiate() -> MenuCellDish {
        return NSBundle.mainBundle().loadNibNamed("MenuCellDish", owner: nil, options: nil).first as! MenuCellDish
    }
}
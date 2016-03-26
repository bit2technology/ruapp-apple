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
    
    @IBOutlet var backgroundImg: MenuCellBgImg!
    @IBOutlet var mealLabel: UILabel!
    @IBOutlet var dayOfWeekLabel: UILabel!
    @IBOutlet var alertWrapper: UIView!
    @IBOutlet var alertImg: UIImageView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var dishesWrapper: UIView!
    var dishLabels: [UILabel] {
        return dishesWrapper.subviews as! [UILabel]
    }
    func dishTitleLabel(idx: Int) -> UILabel {
        return dishLabels[idx * 2]
    }
    func dishNameLabel(idx: Int) -> UILabel {
        return dishLabels[idx * 2 + 1]
    }
    var numberOfDishes: Int = 1 {
        didSet {
            // Clear dishes text
            for dishLabel in dishLabels {
                dishLabel.text = nil
            }
            // Add more dishes if necessary
            if oldValue < numberOfDishes {
                var constraints = [NSLayoutConstraint]()
                for i in dishLabels.count..<numberOfDishes * 2 {
                    let lastDishLabel = dishLabels[i - 2]
                    let newDishLabel = UILabel()
                    newDishLabel.font = lastDishLabel.font
                    newDishLabel.textColor = lastDishLabel.textColor
                    newDishLabel.textAlignment = lastDishLabel.textAlignment
                    newDishLabel.translatesAutoresizingMaskIntoConstraints = false
                    dishesWrapper.addSubview(newDishLabel)
                    let viewsDict = ["lastDishLabel": lastDishLabel, "newDishLabel": newDishLabel]
                    constraints.append(NSLayoutConstraint(item: newDishLabel, attribute: .Leading, relatedBy: .Equal, toItem: lastDishLabel, attribute: .Leading, multiplier: 1, constant: 0))
                    constraints.append(NSLayoutConstraint(item: newDishLabel, attribute: .Trailing, relatedBy: .Equal, toItem: lastDishLabel, attribute: .Trailing, multiplier: 1, constant: 0))
                    if i % 2 == 0 {
                        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[lastDishLabel]-(>=0)-[newDishLabel]", options: [], metrics: nil, views: viewsDict)
                    } else {
                        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[lastDishLabel][newDishLabel]", options: [], metrics: nil, views: viewsDict)
                        constraints.append(NSLayoutConstraint(item: newDishLabel, attribute: .Top, relatedBy: .Equal, toItem: dishLabels[i - 2], attribute: .Top, multiplier: 1, constant: 0))
                    }
                }
                NSLayoutConstraint.activateConstraints(constraints)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.shouldRasterize = true
    }
}

class MenuCellBgImg: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
}

class MenuCellShadow: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 4
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1.5
    }
}
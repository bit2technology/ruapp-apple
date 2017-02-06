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
    func dishTitleLabel(_ idx: Int) -> UILabel {
        return dishLabels[idx * 2]
    }
    func dishNameLabel(_ idx: Int) -> UILabel {
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
                    constraints.append(NSLayoutConstraint(item: newDishLabel, attribute: .leading, relatedBy: .equal, toItem: lastDishLabel, attribute: .leading, multiplier: 1, constant: 0))
                    constraints.append(NSLayoutConstraint(item: newDishLabel, attribute: .trailing, relatedBy: .equal, toItem: lastDishLabel, attribute: .trailing, multiplier: 1, constant: 0))
                    if i % 2 == 0 {
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[lastDishLabel]-(>=0)-[newDishLabel]", options: [], metrics: nil, views: viewsDict)
                    } else {
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[lastDishLabel][newDishLabel]", options: [], metrics: nil, views: viewsDict)
                        constraints.append(NSLayoutConstraint(item: newDishLabel, attribute: .top, relatedBy: .equal, toItem: dishLabels[i - 2], attribute: .top, multiplier: 1, constant: 0))
                    }
                }
                NSLayoutConstraint.activate(constraints)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.rasterizationScale = UIScreen.main.scale
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
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1.5
    }
}

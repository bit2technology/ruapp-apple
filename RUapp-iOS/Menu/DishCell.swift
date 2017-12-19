//
//  DishCell.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 19/12/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import UIKit

class DishCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var typeLabel: UILabel! {
        didSet {
            typeLabel.textColor = .white
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.textColor = .white
        }
    }
    @IBOutlet private var oneLineConstraints: [NSLayoutConstraint]!
    @IBOutlet private var twoLinesConstraints: [NSLayoutConstraint]!
    
    func applyLayout() {
        
        typeLabel.font = UIFont.preferredFont(forTextStyle: .body)
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        if UIApplication.shared.preferredContentSizeCategory.isAccessibility {
            nameLabel.textAlignment = .left
            oneLineConstraints.forEach { $0.priority = .almostNone }
            twoLinesConstraints.forEach { $0.priority = .almostRequired }
        } else {
            nameLabel.textAlignment = .right
            oneLineConstraints.forEach { $0.priority = .almostRequired }
            twoLinesConstraints.forEach { $0.priority = .almostNone }
            
        }
        
        layoutIfNeeded()
    }
}

private extension UIContentSizeCategory {
    var isAccessibility: Bool {
        if #available(iOS 11.0, *) {
            return isAccessibilityCategory
        } else {
            switch self {
            case .accessibilityMedium,
                 .accessibilityLarge,
                 .accessibilityExtraLarge,
                 .accessibilityExtraExtraLarge,
                 .accessibilityExtraExtraExtraLarge:
                return true
            default:
                return false
            }
        }
    }
}

private extension UILayoutPriority {
    static var almostRequired: UILayoutPriority {
        return UILayoutPriority(rawValue: 999)
    }
    static var almostNone: UILayoutPriority {
        return UILayoutPriority(rawValue: 1)
    }
}

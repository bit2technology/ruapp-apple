//
//  DishCell.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 19/12/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import UIKit

class MealCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet private weak var stack: UIStackView!
    
    private static var innerStackQueue: [UIStackView] = []
    
    private func dequeueInnerStack() -> UIStackView {
        if MealCell.innerStackQueue.count > 0 {
            return MealCell.innerStackQueue.removeLast()
        }
        let labels = [UILayoutPriority.defaultHigh, .defaultLow].map { (priority) -> UIView in
            let label = UILabel()
            label.backgroundColor = .black
            label.isOpaque = true
            label.numberOfLines = 0
            label.textColor = .white
            return label
        }
        labels.first!.setContentHuggingPriority(.required, for: .horizontal)
        let stack = UIStackView(arrangedSubviews: labels)
        stack.distribution = .fill
        return stack
    }
    
    private func innerStack(at index: Int) -> UIStackView {
        return stack.arrangedSubviews[index] as! UIStackView
    }
    
    var numberOfDishes: Int {
        get {
            return stack.arrangedSubviews.count
        }
        set {
            let oldValue = numberOfDishes
            if newValue > oldValue {
                for _ in oldValue..<newValue {
                    stack.addArrangedSubview(dequeueInnerStack())
                }
            } else if newValue < oldValue {
                stack.arrangedSubviews[newValue..<oldValue].forEach {
                    stack.removeArrangedSubview($0)
                    MealCell.innerStackQueue.append($0 as! UIStackView)
                    $0.removeFromSuperview()
                }
            }
        }
    }
    
    func dishRow(at index: Int) -> (type: UILabel, name: UILabel) {
        let innerStackViews = innerStack(at: index).arrangedSubviews
        return (innerStackViews.first as! UILabel, innerStackViews.last as! UILabel)
    }
    
    func applyLayout() {
        
        let isAccessibility = UIApplication.shared.preferredContentSizeCategory.isAccessibility
        let axis = isAccessibility ? UILayoutConstraintAxis.vertical : .horizontal
        let alignment = isAccessibility ? UIStackViewAlignment.fill : .firstBaseline
        let spacing = isAccessibility ? 0 : stack.spacing
        let nameTextAlignment = isAccessibility ? NSTextAlignment.left : .right
        let font = UIFont.preferredFont(forTextStyle: .body)
        
        stack.arrangedSubviews.forEach {
            let innerStack = $0 as! UIStackView
            innerStack.axis = axis
            innerStack.alignment = alignment
            innerStack.spacing = spacing
            innerStack.arrangedSubviews.forEach {
                let label = $0 as! UILabel
                label.font = font
            }
            (innerStack.arrangedSubviews.last as! UILabel).textAlignment = nameTextAlignment
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

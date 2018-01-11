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
    
    private static var reusableViewQueue: [(UIView, UIStackView)] = []
    
    private func dequeueInnerStack() -> (UIView, UIStackView) {
        if MealCell.reusableViewQueue.count > 0 {
            return MealCell.reusableViewQueue.removeLast()
        }
        let separator = UIView()
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        separator.addConstraint(NSLayoutConstraint(item: separator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1 / UIScreen.main.scale))
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
        return (separator, stack)
    }
    
    private func innerStack(at index: Int) -> UIStackView {
        return stack.arrangedSubviews[index * 2 + 1] as! UIStackView
    }
    
    var numberOfDishes: Int {
        get {
            return stack.arrangedSubviews.count / 2
        }
        set {
            let oldValue = numberOfDishes
            if newValue > oldValue {
                for _ in oldValue..<newValue {
                    let dequeued = dequeueInnerStack()
                    stack.addArrangedSubview(dequeued.0)
                    stack.addArrangedSubview(dequeued.1)
                }
            } else if newValue < oldValue {
                (newValue..<oldValue).reversed().forEach {
                    let separator = stack.arrangedSubviews[$0 * 2]
                    let innerStack = stack.arrangedSubviews[$0 * 2 + 1] as! UIStackView
                    stack.removeArrangedSubview(separator)
                    stack.removeArrangedSubview(innerStack)
                    MealCell.reusableViewQueue.append((separator, innerStack))
                    separator.removeFromSuperview()
                    innerStack.removeFromSuperview()
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
        
        name.font = font
        (0..<numberOfDishes).forEach {
            let innerStack = self.innerStack(at: $0)
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

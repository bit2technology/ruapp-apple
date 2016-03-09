//
//  MenuController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-28.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

class MenuController: UICollectionViewController {
    
    private var menu = Menu.shared
    private var dateFormatter = NSDateFormatter()
    
    override func needsMenuTypeSelector() -> Bool {
        return true
    }
    
    private func adjustInstets() {
        let topBarHeight = mainController.topBarHeight.constant
        collectionView?.contentInset.top = topBarHeight
        collectionView?.scrollIndicatorInsets.top = topBarHeight
    }
    
    @objc private func updateMenu() {
        
        guard let defaultRestaurant = Restaurant.userDefault else {
            return
            let _ = "Show error"
        }
        
        if defaultRestaurant.id != menu?.restaurantId || menu == nil {
            menu = nil
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityView.color = UIColor.lightGrayColor()
            activityView.startAnimating()
            collectionView?.backgroundView = activityView
            collectionView?.reloadData()
        }
        
        Menu.update(defaultRestaurant) { (menu, error) -> Void in
            
            print(error)
            
            guard let menu = menu else {
                return
                let _ = "Show error"
            }
            
            let animate = self.menu == nil
            self.menu = menu
            if animate {
                UIView.transitionWithView(self.view, duration: 0.2, options: [.TransitionCrossDissolve], animations: {
                    self.collectionView?.reloadData()
                    self.collectionView?.backgroundView = nil
                    self.adjustItemSize()
                }, completion: nil)
            } else {
                self.collectionView?.reloadData()
                self.collectionView?.backgroundView = nil
                self.adjustItemSize()
            }
        }
    }
    
    private func adjustItemSize() {
        
        guard let menuLayout = collectionViewLayout as? LayoutMenu else {
            return
        }
        
        if collectionView?.traitCollection.horizontalSizeClass == .Compact {
            let width = view.bounds.width - 12
            let height = floor(width * 373 / 340)
            let maxHeight = collectionView!.bounds.height - collectionView!.contentInset.top - collectionView!.contentInset.bottom - 30
            if collectionView?.numberOfSections() > 0 && collectionView?.numberOfItemsInSection(0) > 1 {
                menuLayout.itemSize = CGSize(width: width, height: height < maxHeight ? height : maxHeight)
            } else {
                menuLayout.itemSize = CGSize(width: width, height: maxHeight + 18)
            }
        } else {
            menuLayout.itemSize = CGSize(width: 340, height: 373)
        }
    }
    
    private func adjustBehavior() {
        let oneColumnVisible = collectionView?.traitCollection.horizontalSizeClass == .Compact
        collectionView?.decelerationRate = oneColumnVisible ? UIScrollViewDecelerationRateFast : UIScrollViewDecelerationRateNormal
        collectionView?.directionalLockEnabled = oneColumnVisible
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainController.menuTypeSelector.addTarget(collectionView, action: #selector(UICollectionView.reloadData), forControlEvents: .ValueChanged)
        
        dateFormatter.dateFormat = "EEEE"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuController.updateMenu), name: Restaurant.UserDefaultChangedNotification, object: nil)
        
        updateMenu()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustInstets()
        adjustItemSize()
        adjustBehavior()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateMenu()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        adjustInstets()
        adjustItemSize()
        adjustBehavior()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return menu?.meals.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu!.meals[section].count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Menu", forIndexPath: indexPath) as! MenuCell
        let meal = menu!.meals[indexPath.section][indexPath.item]
        let menuKind = Menu.defaultKind
        
        cell.backgroundImg.image = UIImage(named: "Menu\(indexPath.item)\(menuKind.rawValue)")
        cell.dayOfWeekLabel.text = dateFormatter.stringFromDate(meal.opening)
        cell.mealLabel.text = meal.name.uppercaseString
        
        // Alert / Meta
        switch meal.meta {
        case .Strike:
            cell.alertImg.image = UIImage(named: "MetaIconStrike")
            cell.alertLabel.text = NSLocalizedString("MenuController.cell.alertLabel.strike", value: "GREVE!", comment: "Message displayed when the restaurant is not open")
            cell.alertWrapper.hidden = false
        case .Closed where meal.opening.isWeekend:
            cell.alertImg.image = UIImage(named: "MetaIconWeekend")
            cell.alertLabel.text = NSLocalizedString("MenuController.cell.alertLabel.weekend", value: "RU fechado. Vamos aproveitar o final de semana!!!", comment: "Message displayed when the restaurant is not open")
            cell.alertWrapper.hidden = false
        case .Closed:
            cell.alertImg.image = UIImage(named: "MetaIconFrown")
            cell.alertLabel.text = NSLocalizedString("MenuController.cell.alertLabel.closed", value: "Restaurante fechado", comment: "Message displayed when the restaurant is not open")
            cell.alertWrapper.hidden = false
        default:
            cell.alertWrapper.hidden = true
        }
        
        // Present dishes
        if let mealDishes = meal.dishes {
            
            // Filter dishes
            let dishesNotToShow: Dish.Meta
            if menuKind == .Vegetarian {
                dishesNotToShow = .Main
            } else {
                dishesNotToShow = .Vegetarian
            }
            var filteredDishes = [Dish]()
            for dish in mealDishes {
                if dish.meta != dishesNotToShow {
                    filteredDishes.append(dish)
                }
            }
            
            // Store last type, to avoid writing it multiple times
            var lastType: String?
            // Write dishes to cell
            cell.numberOfDishes = filteredDishes.count
            for (idx, dish) in filteredDishes.enumerate() {
                let dishView = cell.dishes[idx]
                dishView.titleLabel.text = dish.type != lastType ? dish.type.uppercaseString : nil
                dishView.nameLabel.text = dish.name
                lastType = dish.type
            }
        } else {
            for dishView in cell.dishes {
                dishView.titleLabel.text = nil
                dishView.nameLabel.text = nil
            }
        }
        
        return cell
    }
}

class LayoutMenu: UICollectionViewLayout {
    
    var itemSize: CGSize = CGSize(width: 308, height: 308) {
        didSet {
            invalidateLayout()
            collectionView?.contentOffset = targetContentOffsetForProposedContentOffset(collectionView!.contentOffset, withScrollingVelocity: CGPoint.zero)
        }
    }
    var space = CGPoint(x: 6, y: 6)
    
    override func collectionViewContentSize() -> CGSize {
        
        guard let sections = collectionView?.numberOfSections() where sections > 0 else {
            return CGSize.zero
        }
        
        return CGSize(width: CGFloat(sections) * (itemSize.width + space.x) + space.x, height: CGFloat(collectionView?.numberOfItemsInSection(0) ?? 0) * (itemSize.height + space.y) + space.y)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attr.frame = CGRect(x: CGFloat(indexPath.section) * (itemSize.width + space.x) + space.x, y: CGFloat(indexPath.item) * (itemSize.height + space.y) + space.y, width: itemSize.width, height: itemSize.height)
        return attr
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let sections = collectionView?.numberOfSections() where sections > 0 else {
            return nil
        }
        
        let itemTotalWidth = itemSize.width + space.x
        let itemTotalHeight = itemSize.height + space.y
        
        var adjRect = rect
        adjRect.size.width -= space.x
        adjRect.size.height -= space.y
        
        let minH = max(Int(adjRect.minX / itemTotalWidth), 0)
        let maxH = min(Int(ceil(adjRect.maxX / itemTotalWidth)), sections)
        let minV = max(Int(adjRect.minY / itemTotalHeight), 0)
        let maxV = min(Int(ceil(adjRect.maxY / itemTotalHeight)), collectionView?.numberOfItemsInSection(0) ?? 0)
        
        var attr = [UICollectionViewLayoutAttributes]()
        for h in minH..<maxH {
            for v in minV..<maxV {
                attr.append(layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: v, inSection: h))!)
            }
        }
        return attr
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard collectionView?.traitCollection.horizontalSizeClass == .Compact,
            let margin = collectionView?.contentInset,
            var visibleSize = collectionView?.bounds.size,
            let originalOffset = collectionView?.contentOffset else {
                return proposedContentOffset
        }
        
        // Get visible size
        visibleSize.width -= margin.left + margin.right
        visibleSize.height -= margin.top + margin.bottom
        // Get item size + space
        let itemTotalWidht = itemSize.width + space.x
        let itemTotalHeight = itemSize.height + space.y
        // Centralize item
        let adjLeftMargin = margin.left + ((visibleSize.width - itemTotalWidht - space.x) / 2)
        let adjTopMargin = margin.top + ((visibleSize.height - itemTotalHeight - space.y) / 2)
        
        // Get current offset and adjust to contentInset, itemSpacing and center
        var adjOffset = originalOffset
        adjOffset.x += adjLeftMargin
        adjOffset.y += adjTopMargin
        
        /// Minimum velocity to change central item
        let minVelocity: CGFloat = 0.2
        
        // Pick item from left or right
        let diffX = adjOffset.x % itemTotalWidht
        var changedX = false
        if velocity.x > minVelocity {
            adjOffset.x += itemTotalWidht - diffX
            changedX = true
        } else if velocity.x < -minVelocity {
            adjOffset.x -= diffX
            changedX = true
        } else {
            adjOffset.x += (diffX > itemTotalWidht / 2 ? itemTotalWidht : 0) - diffX
        }
        
        // Pick item from top or bottom
        let diffY = adjOffset.y % itemTotalHeight
        if velocity.y > minVelocity {
            adjOffset.y += itemTotalHeight - diffY
        } else if velocity.y < -minVelocity {
            adjOffset.y -= diffY
        } else if !changedX { // Avoid adjusting Y if user scrolled only horizontally
            adjOffset.y += (diffY > itemTotalHeight / 2 ? itemTotalHeight : 0) - diffY
        }
        
        // Adjust to contentInset, itemSpacing and center
        adjOffset.x -= adjLeftMargin
        adjOffset.y -= adjTopMargin
        
        // Adjust limit bounds
        let contentSize = collectionView!.contentSize
        adjOffset.x = max(adjOffset.x, 0 - margin.left)
        adjOffset.x = min(adjOffset.x, contentSize.width - visibleSize.width - margin.left)
        adjOffset.y = max(adjOffset.y, -margin.top)
        adjOffset.y = min(adjOffset.y, contentSize.height - visibleSize.height - margin.top)
        
        return adjOffset
    }
}

private extension NSDate {
    var isWeekend: Bool {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let weekdayRange = calendar?.maximumRangeOfUnit(.Weekday)
        let components = calendar?.components(.Weekday, fromDate: self)
        let weekdayOfDate = components?.weekday
        return weekdayOfDate == weekdayRange?.location || weekdayOfDate == weekdayRange?.length
    }
}
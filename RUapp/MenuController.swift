//
//  MenuController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-28.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

let cardapio = ["Arroz": "Branco e Integral",
    "Feijão": "Preto",
    "Macarrão": "Tomate e Manjericão",
    "Guarnição": "Farofa com Cenoura e Ovos",
    "Vegetariano": "Omelete",
    "Prato Principal": "Carne de Panela com Mandioca",
    "Salada": "Almeirão/Acelga, Beterraba Ralada, Abobrinha Ralada"]

class MenuController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    private func adjustInstets() {
        let topBarHeight = mainController.topBarHeight.constant
        collectionView?.contentInset.top = topBarHeight
        collectionView?.scrollIndicatorInsets.top = topBarHeight
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustInstets()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        adjustInstets()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 7
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Menu", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.appBlue()
        
        return cell
    }
}

class LayoutMenu: UICollectionViewLayout {
    
    var itemSize: CGSize = CGSize(width: 300, height: 300) {
        didSet {
            invalidateLayout()
        }
    }
    var space = CGPoint(x: 10, y: 10)
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: CGFloat(collectionView?.numberOfSections() ?? 0) * (itemSize.width + space.x) + space.x, height: CGFloat(collectionView?.numberOfItemsInSection(0) ?? 0) * (itemSize.height + space.y) + space.y)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attr.frame = CGRect(x: CGFloat(indexPath.section) * (itemSize.width + space.x) + space.x, y: CGFloat(indexPath.item) * (itemSize.height + space.y) + space.y, width: itemSize.width, height: itemSize.height)
        return attr
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let itemTotalWidth = itemSize.width + space.x
        let itemTotalHeight = itemSize.height + space.y
        
        var adjRect = rect
        adjRect.size.width -= space.x
        adjRect.size.height -= space.y
        
        let minH = max(Int(adjRect.minX / itemTotalWidth), 0)
        let maxH = min(Int(ceil(adjRect.maxX / itemTotalWidth)), collectionView?.numberOfSections() ?? 0)
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
        
        guard let margin = collectionView?.contentInset,
            var visibleSize = collectionView?.bounds.size else {
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
        let adjRightMargin = margin.top + ((visibleSize.height - itemTotalHeight - space.y) / 2)
        
        // Get current offset and adjust to contentInset, itemSpacing and center
        var adjOffset = collectionView!.contentOffset
        adjOffset.x += adjLeftMargin
        adjOffset.y += adjRightMargin
        
        /// Minimum velocity to change central item
        let minVelocity: CGFloat = 0.2
        
        // Pick item from left or right
        let diffX = adjOffset.x % itemTotalWidht
        if velocity.x > minVelocity {
            adjOffset.x += itemTotalWidht - diffX
        } else if velocity.x < -minVelocity {
            adjOffset.x -= diffX
        } else {
            adjOffset.x += (diffX > itemTotalWidht / 2 ? itemTotalWidht : 0) - diffX
        }
        
        // Pick item from top or bottom
        let diffY = adjOffset.y % itemTotalHeight
        if velocity.y > minVelocity {
            adjOffset.y += itemTotalHeight - diffY
        } else if velocity.y < -minVelocity {
            adjOffset.y -= diffY
        } else {
            adjOffset.y += (diffY > itemTotalHeight / 2 ? itemTotalHeight : 0) - diffY
        }
        
        // Adjust to contentInset, itemSpacing and center
        adjOffset.x -= adjLeftMargin
        adjOffset.y -= adjRightMargin
        
        // Adjust limit bounds
        let contentSize = collectionView!.contentSize
        adjOffset.x = max(adjOffset.x, 0 - margin.left)
        adjOffset.x = min(adjOffset.x, contentSize.width - visibleSize.width - margin.left)
        adjOffset.y = max(adjOffset.y, -margin.top)
        adjOffset.y = min(adjOffset.y, contentSize.height - visibleSize.height - margin.top)
        
        return adjOffset
    }
}
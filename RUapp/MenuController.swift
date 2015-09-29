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

private let reuseIdentifier = "Cell"

class MenuController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

class LayoutMenu: UICollectionViewLayout {
    
    var itemSize: CGSize = CGSize(width: 300, height: 330) {
        didSet {
            invalidateLayout()
        }
    }
    var space: CGPoint = CGPoint(x: 10, y: 10)
    var grid = (h: 7, v: 3)
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: CGFloat(grid.h) * (itemSize.width + space.x) + space.x, height: CGFloat(grid.v) * (itemSize.height + space.y) + space.y)
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
        let maxH = min(Int(ceil(adjRect.maxX / itemTotalWidth)), grid.h)
        let minV = max(Int(adjRect.minY / itemTotalHeight), 0)
        let maxV = min(Int(ceil(adjRect.maxY / itemTotalHeight)), grid.v)
        
        var attr = [UICollectionViewLayoutAttributes]()
        for h in minH..<maxH {
            for v in minV..<maxV {
                attr.append(layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: v, inSection: h))!)
            }
        }
        return attr
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let margin = collectionView!.contentInset
        var usableArea = collectionView!.bounds.size
        usableArea.width -= margin.left + margin.right
        usableArea.height -= margin.top + margin.bottom
        let itemTotalWidht = itemSize.width + space.x
        let itemTotalHeight = itemSize.height + space.y
        let adjLeftMargin = margin.left + ((usableArea.width - itemSize.width) / 2 - space.x) % itemTotalWidht
        let adjRightMargin = margin.top + ((usableArea.height - itemSize.height) / 2 - space.y) % itemTotalHeight
        
        // Get current offset and adjust to contentInset, itemSpacing and center
        var adjOffset = collectionView!.contentOffset
        adjOffset.x += adjLeftMargin
        adjOffset.y += adjRightMargin
        
        // Pick item from left or right
        let diffX = adjOffset.x % itemTotalWidht
        var directionX = velocity.x
        if directionX == 0 {
            directionX = diffX > itemTotalWidht / 2 ? 1 : -1
        }
        if directionX > 0 {
            adjOffset.x += itemTotalWidht - diffX
        } else {
            adjOffset.x -= diffX
        }
        
        // Pick item from top or bottom
        let diffY = adjOffset.y % itemTotalHeight
        var directionY = velocity.y
        if directionY == 0 {
            directionY = diffY > itemTotalHeight / 2 ? 1 : -1
        }
        if directionY > 0 {
            adjOffset.y += itemTotalHeight - diffY
        } else {
            adjOffset.y -= diffY
        }
        
        // Adjust to contentInset, itemSpacing and center
        adjOffset.x -= adjLeftMargin
        adjOffset.y -= adjRightMargin
        
        // Adjust limit bounds
        let contentSize = collectionView!.contentSize
        adjOffset.x = max(adjOffset.x, -margin.left)
        adjOffset.x = min(adjOffset.x, contentSize.width - usableArea.width - margin.left)
        adjOffset.y = max(adjOffset.y, -margin.top)
        adjOffset.y = min(adjOffset.y, contentSize.height - usableArea.height - margin.top)
        
        return adjOffset
    }
}
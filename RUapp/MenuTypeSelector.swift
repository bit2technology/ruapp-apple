//
//  MenuTypeSelector.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit

class MenuTypeSelector: UISegmentedControl {

    var colors = [UIColor.appMeatRed(), UIColor.appVegetarianGreen()]
    private var bgSelected: CALayer!
    override var selectedSegmentIndex: Int {
        didSet {
            valueChanged()
        }
    }
    
    func valueChanged() {
        
        if bgSelected == nil {
            bgSelected = CALayer()
            bgSelected.cornerRadius = 5
            bgSelected.zPosition = -1
            layer.addSublayer(bgSelected)
            traitCollectionDidChange(nil)
        } else {
            let segmentWidth = layer.frame.width / CGFloat(numberOfSegments)
            bgSelected.position.x = (CGFloat(selectedSegmentIndex) + 0.5) * segmentWidth
        }
        
        tintColorDidChange()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let segmentWidth = frame.width / CGFloat(numberOfSegments)
        bgSelected?.frame = CGRect(x: CGFloat(selectedSegmentIndex) * segmentWidth, y: 0, width: segmentWidth, height: frame.height).insetBy(dx: traitCollection.horizontalSizeClass == .Regular ? 0 : 20, dy: 10)
    }
    
    override func tintColorDidChange() {
        if tintAdjustmentMode == .Normal {
            bgSelected?.backgroundColor = colors[selectedSegmentIndex].CGColor
            setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem(), NSForegroundColorAttributeName: UIColor.appLightBlue()], forState: .Normal)
        } else {
            bgSelected?.backgroundColor = UIColor.lightGrayColor().CGColor
            setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem(), NSForegroundColorAttributeName: UIColor.lightGrayColor()], forState: .Normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tintColor = UIColor.clearColor()
        setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem(), NSForegroundColorAttributeName: UIColor.appLightBlue()], forState: .Normal)
        setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Selected)
        addTarget(self, action: "valueChanged", forControlEvents: .ValueChanged)
    }
}

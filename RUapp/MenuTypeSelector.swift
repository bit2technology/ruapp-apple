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
        
        let frame = layer.frame
        let segmentWidth = frame.width / CGFloat(numberOfSegments)
        
        if bgSelected == nil {
            bgSelected = CALayer()
            bgSelected.cornerRadius = 5
            bgSelected.zPosition = -1
            layer.addSublayer(bgSelected)
            bgSelected.frame = CGRect(x: CGFloat(selectedSegmentIndex) * segmentWidth, y: 0, width: segmentWidth, height: frame.height).insetBy(dx: DeviceIsPad ? 0 : 20, dy: 10)
        } else {
            bgSelected.position.x = (CGFloat(selectedSegmentIndex) + 0.5) * segmentWidth
        }
        
        bgSelected.backgroundColor = colors[selectedSegmentIndex].CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tintColor = UIColor.clearColor()
        setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem(), NSForegroundColorAttributeName: UIColor.appLightBlue()], forState: .Normal)
        setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Selected)
        addTarget(self, action: "valueChanged", forControlEvents: .ValueChanged)
    }
}

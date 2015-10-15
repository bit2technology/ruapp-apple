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
    private var bgSelected: UIView!
    override var selectedSegmentIndex: Int {
        didSet {
            valueChanged()
        }
    }
    
    func valueChanged() {
        
        UIView.animateWithDuration(0.15) { () -> Void in
            
            if self.bgSelected == nil {
                let bgSelected = UIView()
                bgSelected.cornerRadius = 6
                bgSelected.layer.zPosition = -1
                self.addSubview(bgSelected)
                self.bgSelected = bgSelected
                self.traitCollectionDidChange(nil)
            } else {
                let segmentWidth = self.layer.frame.width / CGFloat(self.numberOfSegments)
                self.bgSelected.center.x = (CGFloat(self.selectedSegmentIndex) + 0.5) * segmentWidth
            }
            
            self.bgSelected?.backgroundColor = self.colors[self.selectedSegmentIndex]
            self.setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem(), NSForegroundColorAttributeName: UIColor.appLightBlue()], forState: .Normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let segmentWidth = frame.width / CGFloat(numberOfSegments)
        bgSelected?.frame = CGRect(x: CGFloat(selectedSegmentIndex) * segmentWidth, y: 0, width: segmentWidth, height: frame.height).insetBy(dx: traitCollection.horizontalSizeClass == .Regular ? 0 : 20, dy: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tintColor = UIColor.clearColor()
        setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem(), NSForegroundColorAttributeName: UIColor.appLightBlue()], forState: .Normal)
        setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Selected)
        addTarget(self, action: "valueChanged", forControlEvents: .ValueChanged)
    }
}

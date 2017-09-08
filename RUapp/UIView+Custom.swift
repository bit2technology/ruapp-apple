
import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            if newValue > 0 {
                layer.cornerRadius = newValue
                layer.masksToBounds = true
                layer.rasterizationScale = UIScreen.main.scale
                layer.shouldRasterize = true
            } else {
                layer.cornerRadius = 0
                layer.masksToBounds = false
                layer.shouldRasterize = false
            }
        }
    }
}


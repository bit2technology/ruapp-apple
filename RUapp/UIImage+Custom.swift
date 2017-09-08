
import UIKit

extension UIImage {
    
    class func circle(diameter: CGFloat, color: UIColor, insets: UIEdgeInsets = .zero) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: insets.left + diameter + insets.right, height: insets.top + diameter + insets.bottom), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fillEllipse(in: CGRect(x: insets.left, y: insets.top, width: diameter, height: diameter))
        let circleImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return circleImg!
    }
    
    class func roundedRect(radius: CGFloat, color: UIColor, insets: UIEdgeInsets = .zero) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: radius * 2 + insets.left + 1 + insets.right, height: radius * 2 + insets.top + 1 + insets.bottom), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.addPath(UIBezierPath(roundedRect: CGRect(x: insets.left, y: insets.top, width: radius * 2 + 1, height: radius * 2 + 1), cornerRadius: radius).cgPath)
        ctx?.fillPath()
        let rectImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectImg!.resizableImage(withCapInsets: UIEdgeInsets(top: insets.top + radius, left: insets.left + radius, bottom: insets.bottom + radius, right: insets.right + radius))
    }
}

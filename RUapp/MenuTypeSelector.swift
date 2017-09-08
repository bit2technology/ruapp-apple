
import UIKit

class MenuTypeSelector: UISegmentedControl {

    var colors = [UIColor.appDarkRed, .appDarkGreen]
    fileprivate var bgSelected = UIView()
    override var selectedSegmentIndex: Int {
        didSet {
            valueChanged()
        }
    }
    
    func valueChanged() {
        
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            
            let segmentWidth = self.layer.frame.width / CGFloat(self.numberOfSegments)
            self.bgSelected.center.x = (CGFloat(self.selectedSegmentIndex) + 0.5) * segmentWidth
            
            self.bgSelected.backgroundColor = self.colors[self.selectedSegmentIndex]
            self.setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem, NSForegroundColorAttributeName: UIColor.appLightBlue], for: .normal)
        }) 
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let segmentWidth = frame.width / CGFloat(numberOfSegments)
        bgSelected.frame = CGRect(x: CGFloat(selectedSegmentIndex) * segmentWidth, y: 0, width: segmentWidth, height: frame.height).insetBy(dx: traitCollection.horizontalSizeClass == .regular ? 0 : 20, dy: 10)
    }
    
    fileprivate func initialization() {
        
        tintColor = .clear
        setTitleTextAttributes([NSFontAttributeName: UIFont.appBarItem, NSForegroundColorAttributeName: UIColor.appLightBlue], for: .normal)
        setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
        addTarget(self, action: #selector(MenuTypeSelector.valueChanged), for: .valueChanged)
        
        bgSelected.cornerRadius = 6
        bgSelected.layer.zPosition = -1
        self.addSubview(bgSelected)
        self.traitCollectionDidChange(nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }
    
    init() {
        super.init(items: nil)
        initialization()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        initialization()
    }
}

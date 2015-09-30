//
//  VoteController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-29.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

class VoteController: UICollectionViewController {
    
    let votes = Vote.dishes(100)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let topBarHeight = mainController.topBarHeight.constant
        collectionView?.contentInset.top = topBarHeight
        collectionView?.scrollIndicatorInsets.top = topBarHeight
    }
    
    override func needsMenuTypeSelector() -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return votes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Vote", forIndexPath: indexPath) as! VoteCell
        
        cell.bgColor = indexPath.item % 2 == 0 ? UIColor.appBlue() : UIColor.appDarkBlue()
        cell.vote = votes[indexPath.item]
    
        return cell
    }
}

class VoteCell: UICollectionViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var veryGoodBtn: UIButton!
    @IBOutlet var goodBtn: UIButton!
    @IBOutlet var badBtn: UIButton!
    @IBOutlet var didntEatBtn: UIButton!
    @IBOutlet var interactiveMargins: [NSLayoutConstraint]!
    @IBOutlet var bgView: UIView!
    @IBOutlet var selBtnBg: UIImageView!
    @IBOutlet var thankyou: UILabel!
    
    static let selBtnBgImg = UIImage.circle(60, color: UIColor.appLightBlue())
    
    var vote: Vote! {
        didSet {
            configure()
        }
    }
    
    var bgColor: UIColor? {
        get {
            return bgView.backgroundColor
        }
        set {
            bgView.backgroundColor = newValue
            title.backgroundColor = newValue
            selBtnBg.backgroundColor = newValue
        }
    }
    
    private func configure(animating: Bool = false) {
        
        defer {
            layoutIfNeeded()
        }
        
        // CELL DEFAULT START POINT
        
        selBtnBg.alpha = 0
        
        for margin in self.interactiveMargins {
            margin.constant = 9999
        }
        
        for btn in [veryGoodBtn, goodBtn, badBtn, didntEatBtn] {
            btn.alpha = 1
            btn.userInteractionEnabled = true
        }
        
        // IF NOT VOTED, STOP HERE
        guard let voteType = vote.type else {
            return
        }
        
        selBtnBg.alpha = animating ? 0 : 1
        
        for margin in self.interactiveMargins {
            margin.constant = 0
        }
        
        var btns = [veryGoodBtn, goodBtn, badBtn, didntEatBtn] as [UIButton]
        for btn in btns {
            btn.userInteractionEnabled = false
        }
        
        let button: UIButton
        switch voteType {
        case .VeryGood:
            button = veryGoodBtn
        case .Good:
            button = goodBtn
        case .Bad:
            button = badBtn
        default:
            button = didntEatBtn
        }
        btns.removeAtIndex(btns.indexOf(button)!)
        for btn in btns {
            btn.alpha = 0
        }
        
        guard let voteReason = vote.reason else {
            return
        }
        
        guard let voteComment = vote.comment else {
            return
        }
    }
    
    @IBAction func voteTap(sender: UIButton) {
        
        switch sender {
        case veryGoodBtn:
            vote.type = .VeryGood
        case goodBtn:
            vote.type = .Good
        case badBtn:
            vote.type = .Bad
        default:
            vote.type = .DidntEat
        }
        
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut], animations: { () -> Void in
            // Perform changes for current state (Do not animate alpha yet)
            self.configure(true)
        }) { (finished) -> Void in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.selBtnBg.alpha = 1
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        bgView.layer.rasterizationScale = UIScreen.mainScreen().scale
        bgView.layer.shouldRasterize = true
        selBtnBg.image = VoteCell.selBtnBgImg
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
    }
}
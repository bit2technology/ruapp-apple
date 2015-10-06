//
//  VoteController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-29.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

private class AppVote: Vote {
    
    var editingComment = false
    var editingReason = false
    var finishedVotePresented = false
    
    class func dishes(num: Int) -> [AppVote] {
        var votes = [AppVote]()
        for _ in 0..<num {
            votes.append(AppVote())
        }
        return votes
    }
}

class VoteController: UITableViewController {
    
    private let votes = AppVote.dishes(100)
    
    private func adjustInstets() {
        let topBarHeight = mainController.topBarHeight.constant
        tableView?.contentInset.top = topBarHeight + 10
        tableView?.scrollIndicatorInsets.top = topBarHeight
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustInstets()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        adjustInstets()
    }
    
    override func needsMenuTypeSelector() -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return votes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Vote", forIndexPath: indexPath) as! VoteCell
        
        cell.lightStyle = indexPath.row % 2 == 0
        cell.title.text = "Dish name \(indexPath.row)"
        cell.vote = votes[indexPath.item]
    
        return cell
    }
}

class VoteCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var opaqueBgs: [UIView]!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var veryGoodBtn: UIButton!
    @IBOutlet weak var goodBtn: UIButton!
    @IBOutlet weak var badBtn: UIButton!
    @IBOutlet weak var didntEatBtn: UIButton!
    @IBOutlet var interactiveMargins: [NSLayoutConstraint]!
    @IBOutlet weak var selBtnBg: UIImageView!
    
    @IBOutlet weak var thankyou: UILabel!
    @IBOutlet weak var sayMoreBtn: UIButton!
    @IBOutlet weak var undoBtn: UIButton!
    private var sayMoreUndo: UIView {
        return sayMoreBtn.superview!.superview!
    }
    
    @IBOutlet weak var sayMoreField: UITextField!
    @IBOutlet weak var sayMoreSend: UIButton!
    private var sayMoreWrapper: UIView {
        return sayMoreField.superview!
    }
    
    @IBOutlet weak var reasonBad0: UIButton!
    @IBOutlet weak var reasonBad1: UIButton!
    @IBOutlet weak var reasonBad2: UIButton!
    @IBOutlet weak var reasonBad3: UIButton!
    @IBOutlet weak var reasonBad4: UIButton!
    @IBOutlet weak var reasonBad5: UIButton!
    private var reasonBadWrapper: UIView {
        return reasonBad0.superview!
    }
    private var reasonBadTop: [UIButton] {
        return [reasonBad0, reasonBad1, reasonBad2]
    }
    private var reasonBadBottom: [UIButton] {
        return [reasonBad3, reasonBad4, reasonBad5]
    }
    
    @IBOutlet weak var reasonDidntEat0: UIButton!
    @IBOutlet weak var reasonDidntEat1: UIButton!
    @IBOutlet weak var reasonDidntEat2: UIButton!
    private var reasonDidntEatWrapper: UIView {
        return reasonDidntEat0.superview!
    }
    private var reasonDidntEat: [UIButton] {
        return [reasonDidntEat0, reasonDidntEat1, reasonDidntEat2]
    }
    
    @IBOutlet weak var reasonSend: UIButton!
    
    private static let selBtnBgImg = UIImage.circle(60, color: UIColor.appLightBlue())
    private static let circleBtnBg = UIImage.circle(44, color: UIColor.appLightBlue(), insets: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
    private static let commentSendBg = UIImage.circle(25, color: UIColor.appOrange(), insets: UIEdgeInsets(top: 9.5, left: 9.5, bottom: 9.5, right: 9.5))
    
    private static let reasonBadTopInsets = UIEdgeInsets(top: 12, left: 4, bottom: 2, right: 0)
    private static let reasonBadBottomInsets = UIEdgeInsets(top: 2, left: 4, bottom: 12, right: 0)
    private static let reasonBadTopLightBg = UIImage.roundedRect(5, color: UIColor.appLightBlue(), insets: reasonBadTopInsets)
    private static let reasonBadBottomLightBg = UIImage.roundedRect(5, color: UIColor.appLightBlue(), insets: reasonBadBottomInsets)
    private static let reasonBadTopBg = UIImage.roundedRect(5, color: UIColor.appBlue(), insets: reasonBadTopInsets)
    private static let reasonBadBottomBg = UIImage.roundedRect(5, color: UIColor.appBlue(), insets: reasonBadBottomInsets)
    private static let reasonBadTopDarkBg = UIImage.roundedRect(5, color: UIColor.appDarkBlue(), insets: reasonBadTopInsets)
    private static let reasonBadBottomDarkBg = UIImage.roundedRect(5, color: UIColor.appDarkBlue(), insets: reasonBadBottomInsets)
    
    private static let reasonDidntEatInsets = UIEdgeInsets(top: 7, left: 4, bottom: 7, right: 0)
    private static let reasonDidntEatLightBg = UIImage.roundedRect(5, color: UIColor.appLightBlue(), insets: reasonDidntEatInsets)
    private static let reasonDidntEatBg = UIImage.roundedRect(5, color: UIColor.appBlue(), insets: reasonDidntEatInsets)
    private static let reasonDidntEatDarkBg = UIImage.roundedRect(5, color: UIColor.appDarkBlue(), insets: reasonDidntEatInsets)
    
    private static let reasonSendBg = UIImage.circle(26, color: UIColor.appOrange(), insets: UIEdgeInsets(top: 30, left: 3, bottom: 30, right: 18))
    
    private var vote: AppVote! {
        didSet {
            configure(buttonForVoteType(vote.type), complete: true)
            selBtnBg.alpha = vote.type == nil ? 0 : 1
        }
    }
    
    var lightStyle = true {
        didSet {
            let mainColor = lightStyle ? UIColor.appBlue() : UIColor.appDarkBlue()
            let reasonBadTopBgSel = lightStyle ? VoteCell.reasonBadTopDarkBg : VoteCell.reasonBadTopBg
            let reasonBadBottomBgSel = lightStyle ? VoteCell.reasonBadBottomDarkBg : VoteCell.reasonBadBottomBg
            let reasonDidntEatBgSel = lightStyle ? VoteCell.reasonDidntEatDarkBg : VoteCell.reasonDidntEatBg
            for bgView in opaqueBgs {
                bgView.backgroundColor = mainColor
            }
            for btn in reasonBadTop {
                btn.setBackgroundImage(reasonBadTopBgSel, forState: .Selected)
            }
            for btn in reasonBadBottom {
                btn.setBackgroundImage(reasonBadBottomBgSel, forState: .Selected)
            }
            for btn in reasonDidntEat {
                btn.setBackgroundImage(reasonDidntEatBgSel, forState: .Selected)
            }
        }
    }
    
    private func voteTypeForButton(btn: UIButton) -> Vote.VoteType? {
        switch btn {
        case veryGoodBtn:
            return .VeryGood
        case goodBtn:
            return .Good
        case badBtn:
            return .Bad
        case didntEatBtn:
            return .DidntEat
        default:
            return nil
        }
    }
    
    private func buttonForVoteType(type: Vote.VoteType?) -> UIButton? {
        switch type {
        case .VeryGood?:
            return veryGoodBtn
        case .Good?:
            return goodBtn
        case .Bad?:
            return badBtn
        case .DidntEat?:
            return didntEatBtn
        default:
            return nil
        }
    }
    
    private func configure(sender: UIButton?, complete: Bool) {
        
        defer {
            layoutIfNeeded()
        }
        
        thankyou.alpha = 0
        
        // Vote buttons
        var marginConstant: CGFloat = 9999
        var btns = [veryGoodBtn, goodBtn, badBtn, didntEatBtn] as [UIButton]
        for btn in btns {
            btn.alpha = 1
            btn.userInteractionEnabled = true
        }
        
        if let sender = sender, idx = btns.indexOf(sender) {
            marginConstant = 0
            btns.removeAtIndex(idx)
            sender.userInteractionEnabled = false
            
            for btn in btns {
                btn.alpha = 0
            }
        }
        
        for margin in interactiveMargins {
            margin.constant = marginConstant
        }
        
        // Say more
        sayMoreWrapper.alpha = vote.editingComment ? 1 : 0
        sayMoreField.text = vote.comment
        
        reasonBadWrapper.alpha = vote.type == .Bad && vote.editingReason ? 1 : 0
        reasonDidntEatWrapper.alpha = vote.type == .DidntEat && vote.editingReason ? 1 : 0
        
        guard complete else {
            return
        }
        
        // Layout by vote type
        if vote.type == nil || vote.editingComment || vote.editingReason {
            sayMoreUndo.alpha = 0
        } else {
            sayMoreUndo.alpha = 1
        }
        
        reasonSend.alpha = vote.editingReason ? 1 : 0
        if let voteReason = vote.reason {
            if vote.type == .Bad {
                for (idx, btn) in (reasonBadTop + reasonBadBottom).enumerate() {
                    btn.selected = voteReason.contains(idx)
                }
            } else if vote.type == .DidntEat {
                for (idx, btn) in reasonDidntEat.enumerate() {
                    btn.selected = voteReason.contains(idx)
                }
            }
        }
    }
    
    @IBAction func voteTap(sender: UIButton) {
        
        // Set model
        vote.type = voteTypeForButton(sender)
        vote.editingComment = vote.type == .Good
        vote.editingReason = vote.type == .Bad || vote.type == .DidntEat
        if vote.editingReason {
            vote.reason = Set<Int>()
            for reasonBtn in reasonBadTop + reasonBadBottom + reasonDidntEat {
                reasonBtn.selected = false
            }
        }
        let showFinishedVote = vote.type == .VeryGood && !vote.finishedVotePresented
        
        // Animate vote
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut], animations: { () -> Void in
            
            self.configure(sender, complete: false)
            self.thankyou.alpha = showFinishedVote ? 1 : 0
            self.reasonSend.alpha = self.vote.editingReason ? 1 : 0
            
        }) { (finished) -> Void in
            
            // If vote is Very Good, finish voting process
            if showFinishedVote {
                self.vote.finishedVotePresented = true
                UIView.animateWithDuration(0.5, delay: 1, options: [.CurveEaseInOut], animations: { () -> Void in
                    self.thankyou.alpha = 0
                    self.sayMoreUndo.alpha = 1
                }, completion: nil)
            }
            else if self.vote.editingComment {
                self.sayMoreField.becomeFirstResponder()
            }
        }
        
        // Animate selected button background
        UIView.animateWithDuration(0.2, delay: 0.3, options: [.CurveEaseIn], animations: { () -> Void in
            self.selBtnBg.alpha = 1
        }, completion: nil)
    }
    
    @IBAction func sendCommentTap() {
        
        sayMoreField.resignFirstResponder()
        vote.editingComment = false
        let showFinishedVote = vote.type == .Good && !vote.finishedVotePresented
        
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut], animations: { () -> Void in
            
            self.sayMoreWrapper.alpha = 0
            if showFinishedVote {
                self.thankyou.alpha = 1
            } else {
                self.sayMoreUndo.alpha = 1
            }
            
        }) { (finished) -> Void in
            
            // If vote is Good, finish voting process
            if showFinishedVote {
                self.vote.finishedVotePresented = true
                UIView.animateWithDuration(0.5, delay: 1, options: [.CurveEaseInOut], animations: { () -> Void in
                    self.thankyou.alpha = 0
                    self.sayMoreUndo.alpha = 1
                }, completion: nil)
            }
        }
    }
    
    @IBAction func reasonBadTap(sender: UIButton) {
        
        guard let idx = (reasonBadTop + reasonBadBottom).indexOf(sender) else {
            return
        }
        
        if sender.selected {
            sender.selected = false
            vote.reason?.remove(idx)
        } else {
            sender.selected = true
            vote.reason?.insert(idx)
        }
    }
    
    @IBAction func reasonDidntEatTap(sender: UIButton) {
        
        guard let idx = reasonDidntEat.indexOf(sender) else {
            return
        }
        
        if sender.selected {
            sender.selected = false
            vote.reason?.remove(idx)
        } else {
            sender.selected = true
            vote.reason?.insert(idx)
        }
    }
    
    @IBAction func sendReasonTap() {
        
        vote.editingReason = false
        
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut], animations: { () -> Void in
            
            self.reasonBadWrapper.alpha = 0
            self.reasonDidntEatWrapper.alpha = 0
            self.reasonSend.alpha = 0
            self.thankyou.alpha = 1
            
        }) { (finished) -> Void in
            
            self.vote.finishedVotePresented = true
            UIView.animateWithDuration(0.5, delay: 1, options: [.CurveEaseInOut], animations: { () -> Void in
                self.thankyou.alpha = 0
                self.sayMoreUndo.alpha = 1
            }, completion: nil)
        }
    }
    
    @IBAction func sayMoreBtnTap() {
        
        vote.editingComment = true
        
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut], animations: { () -> Void in
            self.sayMoreUndo.alpha = 0
            self.sayMoreWrapper.alpha = 1
        }) { (finished) -> Void in
            self.sayMoreField.becomeFirstResponder()
        }
    }
    
    @IBAction func undoTap() {
        
        vote.type = nil
        vote.reason = nil
        vote.comment = nil
        vote.editingComment = false
        vote.finishedVotePresented = false
        
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut], animations: { () -> Void in
            self.configure(nil, complete: true)
            self.selBtnBg.alpha = 0
        }, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selBtnBg.image = VoteCell.selBtnBgImg
        sayMoreBtn.setBackgroundImage(VoteCell.circleBtnBg, forState: .Normal)
        undoBtn.setBackgroundImage(VoteCell.circleBtnBg, forState: .Normal)
        sayMoreSend.setBackgroundImage(VoteCell.commentSendBg, forState: .Normal)
        reasonSend.setBackgroundImage(VoteCell.reasonSendBg, forState: .Normal)
        for btn in reasonBadTop {
            btn.setBackgroundImage(VoteCell.reasonBadTopLightBg, forState: .Normal)
        }
        for btn in reasonBadBottom {
            btn.setBackgroundImage(VoteCell.reasonBadBottomLightBg, forState: .Normal)
        }
        for btn in reasonDidntEat {
            btn.setBackgroundImage(VoteCell.reasonDidntEatLightBg, forState: .Normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendCommentTap()
        return true
    }
    
    @IBAction func textEdited(textField: UITextField) {
        vote.comment = textField.text
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            if newValue > 0 {
                layer.cornerRadius = newValue
                layer.masksToBounds = true
                layer.rasterizationScale = UIScreen.mainScreen().scale
                layer.shouldRasterize = true
            } else {
                layer.cornerRadius = 0
                layer.masksToBounds = false
                layer.shouldRasterize = false
            }
        }
    }
}
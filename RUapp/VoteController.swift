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
}

class VoteController: UITableViewController {
    
    fileprivate var currentMeal: Meal? {
        didSet {
            if currentMeal?.opening != oldValue?.opening {
                
                guard let votables = currentMeal?.votables else {
                    return
                }
                
                var votes = [AppVote]()
                for votable in votables {
                    votes.append(AppVote(item: votable))
                }
                self.allVotes = votes
                
                updateVotes()
            }
        }
    }
    
    fileprivate var votes: [AppVote]?
    
    fileprivate var allVotes: [AppVote]?
    
    fileprivate var presented = false
    @objc fileprivate func updateVotes() {
        
        if let allVotes = allVotes {
            self.votes = filterVotes(allVotes)
        } else {
            self.votes = nil
        }
        
        if presented {
            tableView.reloadData()
        }
    }
    
    fileprivate func filterVotes(_ votes: [AppVote]) -> [AppVote] {
        let dishesNotToShow = Menu.defaultKind == .traditional ? Dish.Meta.vegetarian : .main
        var filteredVotes = [AppVote]()
        for vote in votes {
            if vote.item.meta != dishesNotToShow {
                filteredVotes.append(vote)
            }
        }
        return filteredVotes
    }
    
    fileprivate func adjustInstets() {
        let topBarHeight = mainController.topBarHeight.constant
        tableView?.contentInset.top = topBarHeight + 10
        tableView?.scrollIndicatorInsets.top = topBarHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainController.menuTypeSelector.addTarget(self, action: #selector(VoteController.updateVotes), for: .valueChanged)
        currentMeal = Menu.shared?.currentMeal
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustInstets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presented = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        adjustInstets()
    }
    
    override func needsMenuTypeSelector() -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return votes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Vote", for: indexPath) as! VoteCell
        
        cell.lightStyle = indexPath.row % 2 == 0
        cell.vote = votes![indexPath.item]
    
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
    fileprivate var sayMoreUndo: UIView {
        return sayMoreBtn.superview!.superview!
    }
    
    @IBOutlet weak var sayMoreField: UITextField!
    @IBOutlet weak var sayMoreSend: UIButton!
    fileprivate var sayMoreWrapper: UIView {
        return sayMoreField.superview!
    }
    
    @IBOutlet weak var reasonBad0: UIButton!
    @IBOutlet weak var reasonBad1: UIButton!
    @IBOutlet weak var reasonBad2: UIButton!
    @IBOutlet weak var reasonBad3: UIButton!
    @IBOutlet weak var reasonBad4: UIButton!
    @IBOutlet weak var reasonBad5: UIButton!
    fileprivate var reasonBadWrapper: UIView {
        return reasonBad0.superview!
    }
    fileprivate var reasonBadTop: [UIButton] {
        return [reasonBad0, reasonBad1, reasonBad2]
    }
    fileprivate var reasonBadBottom: [UIButton] {
        return [reasonBad3, reasonBad4, reasonBad5]
    }
    
    @IBOutlet weak var reasonDidntEat0: UIButton!
    @IBOutlet weak var reasonDidntEat1: UIButton!
    @IBOutlet weak var reasonDidntEat2: UIButton!
    fileprivate var reasonDidntEatWrapper: UIView {
        return reasonDidntEat0.superview!
    }
    fileprivate var reasonDidntEat: [UIButton] {
        return [reasonDidntEat0, reasonDidntEat1, reasonDidntEat2]
    }
    
    @IBOutlet weak var reasonSend: UIButton!
    
    fileprivate static let selBtnBgImg = UIImage.circle(diameter: 60, color: UIColor.appLightBlue())
    fileprivate static let circleBtnBg = UIImage.circle(diameter: 44, color: UIColor.appLightBlue(), insets: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
    fileprivate static let commentSendBg = UIImage.circle(diameter: 25, color: UIColor.appOrange(), insets: UIEdgeInsets(top: 9.5, left: 9.5, bottom: 9.5, right: 9.5))
    
    fileprivate static let reasonCornerRadius: CGFloat = 4
    fileprivate static let reasonSendBg = UIImage.circle(diameter: 26, color: UIColor.appOrange(), insets: UIEdgeInsets(top: 30, left: 3, bottom: 30, right: 18))
    
    fileprivate static let reasonBadTopInsets = UIEdgeInsets(top: 12, left: 4, bottom: 2, right: 0)
    fileprivate static let reasonBadBottomInsets = UIEdgeInsets(top: 2, left: 4, bottom: 12, right: 0)
    fileprivate static let reasonBadTopLightBg = UIImage.roundedRect(radius: reasonCornerRadius, color: UIColor.appLightBlue(), insets: reasonBadTopInsets)
    fileprivate static let reasonBadBottomLightBg = UIImage.roundedRect(radius: reasonCornerRadius, color: UIColor.appLightBlue(), insets: reasonBadBottomInsets)
    fileprivate static let reasonBadTopBg = UIImage.roundedRect(radius: reasonCornerRadius, color: UIColor.appBlue(), insets: reasonBadTopInsets)
    fileprivate static let reasonBadBottomBg = UIImage.roundedRect(radius: reasonCornerRadius, color: UIColor.appBlue(), insets: reasonBadBottomInsets)
    fileprivate static let reasonBadTopDarkBg = UIImage.roundedRect(radius: reasonCornerRadius, color: UIColor.appDarkBlue(), insets: reasonBadTopInsets)
    fileprivate static let reasonBadBottomDarkBg = UIImage.roundedRect(radius: reasonCornerRadius, color: UIColor.appDarkBlue(), insets: reasonBadBottomInsets)
    
    fileprivate static let reasonDidntEatInsets = UIEdgeInsets(top: 7, left: 4, bottom: 7, right: 0)
    fileprivate static let reasonDidntEatLightBg = UIImage.roundedRect(radius: reasonCornerRadius, color: UIColor.appLightBlue(), insets: reasonDidntEatInsets)
    fileprivate static let reasonDidntEatBg = UIImage.roundedRect(radius: reasonCornerRadius, color: UIColor.appBlue(), insets: reasonDidntEatInsets)
    fileprivate static let reasonDidntEatDarkBg = UIImage.roundedRect(radius: reasonCornerRadius, color: UIColor.appDarkBlue(), insets: reasonDidntEatInsets)
    
    fileprivate var vote: AppVote! {
        didSet {
            configure(button(for: vote.type), complete: true)
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
                btn.setBackgroundImage(reasonBadTopBgSel, for: .selected)
            }
            for btn in reasonBadBottom {
                btn.setBackgroundImage(reasonBadBottomBgSel, for: .selected)
            }
            for btn in reasonDidntEat {
                btn.setBackgroundImage(reasonDidntEatBgSel, for: .selected)
            }
        }
    }
    
    fileprivate func voteType(for button: UIButton) -> Vote.VoteType? {
        switch button {
        case veryGoodBtn:
            return .veryGood
        case goodBtn:
            return .good
        case badBtn:
            return .bad
        case didntEatBtn:
            return .didntEat
        default:
            return nil
        }
    }
    
    fileprivate func button(for voteType: Vote.VoteType?) -> UIButton? {
        switch voteType {
        case .veryGood?:
            return veryGoodBtn
        case .good?:
            return goodBtn
        case .bad?:
            return badBtn
        case .didntEat?:
            return didntEatBtn
        default:
            return nil
        }
    }
    
    fileprivate func configure(_ sender: UIButton?, complete: Bool) {
        
        defer {
            layoutIfNeeded()
        }
        
        title.text = vote.item.name
        
        thankyou.alpha = 0
        
        // Vote buttons
        var marginConstant: CGFloat = 9999
        var btns = [veryGoodBtn, goodBtn, badBtn, didntEatBtn] as [UIButton]
        for btn in btns {
            btn.alpha = 1
            btn.isUserInteractionEnabled = true
        }
        
        if let sender = sender, let idx = btns.index(of: sender) {
            marginConstant = 0
            btns.remove(at: idx)
            sender.isUserInteractionEnabled = false
            
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
        
        reasonBadWrapper.alpha = vote.type == .bad && vote.editingReason ? 1 : 0
        reasonDidntEatWrapper.alpha = vote.type == .didntEat && vote.editingReason ? 1 : 0
        
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
            if vote.type == .bad {
                for (idx, btn) in (reasonBadTop + reasonBadBottom).enumerated() {
                    btn.isSelected = voteReason.contains(idx)
                }
            } else if vote.type == .didntEat {
                for (idx, btn) in reasonDidntEat.enumerated() {
                    btn.isSelected = voteReason.contains(idx)
                }
            }
        }
    }
    
    @IBAction func voteTap(_ sender: UIButton) {
        
        // Set model
        vote.type = voteType(for: sender)
        vote.editingComment = vote.type == .good
        vote.editingReason = vote.type == .bad || vote.type == .didntEat
        if vote.editingReason {
            vote.reason = Set<Int>()
            for reasonBtn in reasonBadTop + reasonBadBottom + reasonDidntEat {
                reasonBtn.isSelected = false
            }
        }
        let showFinishedVote = vote.type == .veryGood && !vote.finishedVotePresented
        
        // Animate vote
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.configure(sender, complete: false)
            self.thankyou.alpha = showFinishedVote ? 1 : 0
            self.reasonSend.alpha = self.vote.editingReason ? 1 : 0
            
        }) { (finished) -> Void in
            
            // If vote is Very Good, finish voting process
            if showFinishedVote {
                self.vote.finishedVotePresented = true
                UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.thankyou.alpha = 0
                    self.sayMoreUndo.alpha = 1
                }, completion: nil)
            }
            else if self.vote.editingComment {
                self.sayMoreField.becomeFirstResponder()
            }
        }
        
        // Animate selected button background
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [.curveEaseIn], animations: { () -> Void in
            self.selBtnBg.alpha = 1
        }, completion: nil)
    }
    
    @IBAction func sendCommentTap() {
        
        sayMoreField.resignFirstResponder()
        vote.editingComment = false
        let showFinishedVote = vote.type == .good && !vote.finishedVotePresented
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
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
                UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.thankyou.alpha = 0
                    self.sayMoreUndo.alpha = 1
                }, completion: nil)
            }
        }
    }
    
    @IBAction func reasonBadTap(_ sender: UIButton) {
        
        guard let idx = (reasonBadTop + reasonBadBottom).index(of: sender) else {
            return
        }
        
        if sender.isSelected {
            sender.isSelected = false
            let _ = vote.reason?.remove(idx)
        } else {
            sender.isSelected = true
            vote.reason?.insert(idx)
        }
    }
    
    @IBAction func reasonDidntEatTap(_ sender: UIButton) {
        
        guard let idx = reasonDidntEat.index(of: sender) else {
            return
        }
        
        if sender.isSelected {
            sender.isSelected = false
            let _ = vote.reason?.remove(idx)
        } else {
            sender.isSelected = true
            vote.reason?.insert(idx)
        }
    }
    
    @IBAction func sendReasonTap() {
        
        vote.editingReason = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.reasonBadWrapper.alpha = 0
            self.reasonDidntEatWrapper.alpha = 0
            self.reasonSend.alpha = 0
            self.thankyou.alpha = 1
            
        }) { (finished) -> Void in
            
            self.vote.finishedVotePresented = true
            UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.thankyou.alpha = 0
                self.sayMoreUndo.alpha = 1
            }, completion: nil)
        }
    }
    
    @IBAction func sayMoreBtnTap() {
        
        vote.editingComment = true
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
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
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.configure(nil, complete: true)
            self.selBtnBg.alpha = 0
        }, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selBtnBg.image = VoteCell.selBtnBgImg
        sayMoreBtn.setBackgroundImage(VoteCell.circleBtnBg, for: UIControlState())
        undoBtn.setBackgroundImage(VoteCell.circleBtnBg, for: UIControlState())
        sayMoreSend.setBackgroundImage(VoteCell.commentSendBg, for: UIControlState())
        reasonSend.setBackgroundImage(VoteCell.reasonSendBg, for: UIControlState())
        for btn in reasonBadTop {
            btn.setBackgroundImage(VoteCell.reasonBadTopLightBg, for: UIControlState())
        }
        for btn in reasonBadBottom {
            btn.setBackgroundImage(VoteCell.reasonBadBottomLightBg, for: UIControlState())
        }
        for btn in reasonDidntEat {
            btn.setBackgroundImage(VoteCell.reasonDidntEatLightBg, for: UIControlState())
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCommentTap()
        return true
    }
    
    @IBAction func textEdited(_ textField: UITextField) {
        vote.comment = textField.text
    }
}

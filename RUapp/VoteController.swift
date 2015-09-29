//
//  VoteController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-29.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

private let reuseIdentifier = "Cell"

class VoteController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}

class Cedula: UICollectionViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var veryGoodBtn: UIButton!
    @IBOutlet var goodBtn: UIButton!
    @IBOutlet var badBtn: UIButton!
    @IBOutlet var didntEatBtn: UIButton!
    @IBOutlet var interactiveMargins: [NSLayoutConstraint]!
    @IBOutlet var bgView: UIView!
    @IBOutlet var selBtnBg: UIImageView!
    
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
    
    private func configure() {
        
        func jaVotouTipo() {
            
            for margem in self.interactiveMargins {
                margem.constant = 0
            }
            
            var botoes = [veryGoodBtn, goodBtn, badBtn, didntEatBtn] as [UIButton]
            for botao in botoes {
                botao.userInteractionEnabled = false
            }
            
            let botao: UIButton
            switch vote.type! {
            case .VeryGood:
                botao = veryGoodBtn
            case .Good:
                botao = goodBtn
            case .Bad:
                botao = badBtn
            default:
                botao = didntEatBtn
            }
            botoes.removeAtIndex(botoes.indexOf(botao)!)
            for botao in botoes {
                botao.alpha = 0
            }
        }
        
        if let votoComentario = vote.comment {
            
            jaVotouTipo()
            
        } else if let votoMotivos = vote.reason {
            
            jaVotouTipo()
            
        } else if let votoTipo = vote.type {
            
            jaVotouTipo()
            
        } else {
            
            for margem in self.interactiveMargins {
                margem.constant = 9999
            }
            
            for botao in [veryGoodBtn, goodBtn, badBtn, didntEatBtn] {
                botao.alpha = 1
                botao.userInteractionEnabled = true
            }
        }
        
        layoutIfNeeded()
    }
    
    @IBAction func votou(agente: UIButton) {
        
        switch agente {
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
            self.configure()
            }) { (finished) -> Void in
                
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        bgView.layer.rasterizationScale = UIScreen.mainScreen().scale
        bgView.layer.shouldRasterize = true
    }
}
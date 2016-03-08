//
//  RegisterController.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-25.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import UIKit
import RUappService

class RegisterController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var institutionField: UITextField!
    @IBOutlet weak var studentIdField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var keyboardHeight: NSLayoutConstraint!
    
    private weak var institutionsCont: RegisterInstitutionListController?
    
    private var institution: Institution? {
        didSet {
            institutionField.text = institution?.name
        }
    }
    
    @IBAction func unwindToRegistration(segue: UIStoryboardSegue) {
        switch segue.identifier {
        case "Institutions To Registration"?:
            let institutionsCont = segue.sourceViewController as? RegisterInstitutionListController
            institution = institutionsCont?.selected
            textEdited()
            // If student ID empty, go to edit it.
            if !(studentIdField.text?.characters.count > 0) {
                studentIdField.becomeFirstResponder()
            }
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "Registration To Institutions"?:
            let navCont = segue.destinationViewController as? UINavigationController
            let popover = navCont?.popoverPresentationController
            popover?.sourceRect = institutionField.frame
            popover?.backgroundColor = UIColor.whiteColor()
            institutionsCont = navCont?.viewControllers.first as? RegisterInstitutionListController
            institutionsCont?.selected = institution
        default:
            break
        }
    }
    
    func keyboardChanged(notification: NSNotification) {
        
        guard let info = notification.userInfo, keyboardFrame = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
            return
        }
        
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval ?? 0.25
        let curve = UIViewAnimationOptions(rawValue: info[UIKeyboardAnimationCurveUserInfoKey] as? UInt ?? 7)
        UIView.animateWithDuration(duration, delay: 0, options: [curve], animations: { () -> Void in
            self.keyboardHeight.constant = self.view.frame.height - keyboardFrame.origin.y
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func tapOnNothing() {
        view.endEditing(true)
    }
    
    @IBAction func textEdited() {
        if institution != nil && studentIdField.text?.characters.count > 0 && nameField.text?.characters.count > 0 {
            doneBtn.enabled = true
        } else {
            doneBtn.enabled = false
        }
    }
    
    @IBAction func doneTap() {
        
        guard let institution = institution,
            let name = nameField.text where name.characters.count > 0,
            let studentId = studentIdField.text where studentId.characters.count > 0 else {
                return
        }
        
        let controls = [institutionField, studentIdField, nameField, doneBtn]
        for item in controls {
            item.enabled = false
        }
        indicator.hidden = false
        
        Student.register(name: name, numberPlate: studentId, on: institution) { (student, error) -> Void in
            
            guard student != nil else {
                for item in controls {
                    item.enabled = true
                }
                self.indicator.hidden = true
                let alert = UIAlertController(title: NSLocalizedString("RegisterController.registerStudent.errorTitle", value: "There was an error. Please, try again.", comment: "Error title for when it was not possible to register a new student"), message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("RegisterController.registerStudent.errorBtnTitle", value: "OK", comment: "Error button title for when it was not possible to register a new student"), style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            self.performSegueWithIdentifier("Registration To Main", sender: nil)
        }
    }
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        institutionsCont?.traitCollectionDidChange(previousTraitCollection)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let student = Student.shared
        nameField.text = student?.name
        studentIdField.text = student?.numberPlate
        institution = Institution.shared
        textEdited()
                
        let frameBtn = doneBtn.bounds
        UIGraphicsBeginImageContextWithOptions(frameBtn.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, UIColor.appLightBlue().CGColor)
        CGContextFillEllipseInRect(ctx, frameBtn)
        doneBtn.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), forState: .Normal)
        UIGraphicsEndImageContext()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegisterController.keyboardChanged(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if textField == institutionField {
            view.endEditing(true)
            performSegueWithIdentifier("Registration To Institutions", sender: textField)
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        switch textField {
        case nameField:
            institutionField.becomeFirstResponder()
        case studentIdField:
            studentIdField.resignFirstResponder()
        default:
            break
        }
        
        return true
    }
}

class RegisterInstitutionListController: UITableViewController {
    
    private var list: [Institution]?
    weak var selected: Institution?
    
    @IBAction func cancelTap() {
        performSegueWithIdentifier("Cancel", sender: nil)
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if presentingViewController?.traitCollection.horizontalSizeClass == .Regular {
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(RegisterInstitutionListController.cancelTap))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationItem.title?.uppercaseString
        
        Institution.list { (list, error) -> Void in
            
            if list == nil {
                let errorMsg = UILabel()
                errorMsg.text = NSLocalizedString("RegisterInstitutionListController.downloadList.error", value: "There was an error. Please, try again.", comment: "Error message for when it was not possible to download the institutions list")
                errorMsg.numberOfLines = 0
                errorMsg.font = UIFont(name: "Dosis-Regular", size: 20)
                errorMsg.textColor = UIColor.appError()
                errorMsg.textAlignment = .Center
                self.tableView.backgroundView = errorMsg
                self.tableView.separatorStyle = .None
            }
            
            self.list = list ?? []
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let list = list else {
            return tableView.dequeueReusableCellWithIdentifier("Loading", forIndexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Institution", forIndexPath: indexPath)
        let inst = list[indexPath.row]
        
        cell.textLabel?.text = inst.name
        cell.accessoryType = inst.id == selected?.id ? .Checkmark : .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = list![indexPath.row]
        performSegueWithIdentifier("Institutions To Registration", sender: nil)
    }
}
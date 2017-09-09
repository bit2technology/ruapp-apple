
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
    
    fileprivate weak var institutionsCont: RegisterInstitutionListController?
    
    fileprivate var institution: Institution? {
        didSet {
            institutionField.text = institution?.name
        }
    }
    
    @IBAction func unwindToRegistration(_ segue: UIStoryboardSegue) {
        switch segue.identifier {
        case "Institutions To Registration"?:
            let institutionsCont = segue.source as? RegisterInstitutionListController
            institution = institutionsCont?.selected
            textEdited()
            // If student ID empty, go to edit it.
            if !((studentIdField.text?.characters.count ?? 0) > 0) {
                studentIdField.becomeFirstResponder()
            }
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Registration To Institutions"?:
            let navCont = segue.destination as? UINavigationController
            let popover = navCont?.popoverPresentationController
            popover?.sourceRect = institutionField.frame
            popover?.backgroundColor = UIColor.white
            institutionsCont = navCont?.viewControllers.first as? RegisterInstitutionListController
            institutionsCont?.selected = institution
        default:
            break
        }
    }
    
    func keyboardChanged(_ notification: Notification) {
        
        guard let info = notification.userInfo, let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }
        
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curve = UIViewAnimationOptions(rawValue: info[UIKeyboardAnimationCurveUserInfoKey] as? UInt ?? 7)
        UIView.animate(withDuration: duration, delay: 0, options: [curve], animations: { () -> Void in
            self.keyboardHeight.constant = self.view.frame.height - keyboardFrame.origin.y
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func tapOnNothing() {
        view.endEditing(true)
    }
    
    @IBAction func textEdited() {
        if institution != nil && (studentIdField.text?.characters.count ?? 0) > 0 && (nameField.text?.characters.count ?? 0) > 0 {
            doneBtn.isEnabled = true
        } else {
            doneBtn.isEnabled = false
        }
    }
    
    @IBAction func doneTap() {
        
        guard let institution = institution,
            let name = nameField.text, name.characters.count > 0,
            let studentId = studentIdField.text, studentId.characters.count > 0 else {
                return
        }
        
        let controls = [institutionField, studentIdField, nameField, doneBtn] as [UIControl]
        controls.forEach {
            $0.isEnabled = false
        }
        indicator.isHidden = false
        
        Student.register(name: name, numberPlate: studentId, on: institution) { (result) in
            switch result {
            case .success(_):
                self.performSegue(withIdentifier: "Registration To Main", sender: nil)
            case .failure(_):
                controls.forEach {
                    $0.isEnabled = true
                }
                self.indicator.isHidden = true
                let alert = UIAlertController(title: NSLocalizedString("RegisterController.registerStudent.errorTitle", value: "There was an error. Please, try again.", comment: "Error title for when it was not possible to register a new student"), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("RegisterController.registerStudent.errorBtnTitle", value: "OK", comment: "Error button title for when it was not possible to register a new student"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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
        ctx?.setFillColor(UIColor.appLightBlue.cgColor)
        ctx?.fillEllipse(in: frameBtn)
        doneBtn.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), for: .normal)
        UIGraphicsEndImageContext()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterController.keyboardChanged(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == institutionField {
            view.endEditing(true)
            performSegue(withIdentifier: "Registration To Institutions", sender: textField)
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
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
    
    fileprivate var list: [Institution]?
    weak var selected: Institution?
    
    @IBAction func cancelTap() {
        performSegue(withIdentifier: "Cancel", sender: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if presentingViewController?.traitCollection.horizontalSizeClass == .regular {
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(RegisterInstitutionListController.cancelTap))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationItem.title?.uppercased()
        
        Institution.list { (result) -> Void in
            
            switch result {
            case .success(let list):
                self.list = list
            case .failure(_):
                let errorMsg = UILabel()
                errorMsg.text = NSLocalizedString("RegisterInstitutionListController.downloadList.error", value: "There was an error. Please, try again.", comment: "Error message for when it was not possible to download the institutions list")
                errorMsg.numberOfLines = 0
                errorMsg.font = UIFont(name: "Dosis-Regular", size: 20)
                errorMsg.textColor = .appRed
                errorMsg.textAlignment = .center
                self.tableView.backgroundView = errorMsg
                self.tableView.separatorStyle = .none
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let list = list else {
            return tableView.dequeueReusableCell(withIdentifier: "Loading", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Institution", for: indexPath)
        let inst = list[indexPath.row]
        
        cell.textLabel?.text = inst.name
        cell.accessoryType = inst.id == selected?.id ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = list![indexPath.row]
        performSegue(withIdentifier: "Institutions To Registration", sender: nil)
    }
}

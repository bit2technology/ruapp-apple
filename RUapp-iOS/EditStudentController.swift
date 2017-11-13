//
//  EditStudentController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import RUappShared

class EditStudentController: UITableViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var institutionField: UITextField!
    @IBOutlet weak var numberPlateField: UITextField!
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.alpha = 0
        spinner.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        return spinner
    }()
    
    private weak var finiOp: FinishSaveStudentOperation?
    
    @IBAction private func fieldEdited(sender: UITextField) {
        let student = Student.current
        let value = sender.text
        switch sender {
        case nameField:
            student.name = value
        case numberPlateField:
            student.numberPlate = value
        default:
            fatalError("Unknown text field")
        }
        navigationItem.rightBarButtonItem!.isEnabled = student.isValid
    }
    
    @IBAction func cancelButtonPressed() {
        view.endEditing(true)
        Student.current.managedObjectContext!.rollback()
        performSegue(withIdentifier: "UnwindToRoot", sender: nil)
    }
    
    @IBAction func doneButtonPressed() {
        view.endEditing(true)
        guard Student.current.hasChanges else {
            performSegue(withIdentifier: "UnwindToRoot", sender: nil)
            return
        }
        setLoadingLayout(true)
        finiOp = FinishSaveStudentOperation(controller: self)
    }
    
    private func setLoadingLayout(_ loading: Bool) {
        let navView = navigationController!.view!
        if loading {
            spinner.frame = navView.bounds
            navView.addSubview(spinner)
            navView.leftAnchor.constraint(equalTo: spinner.leftAnchor).isActive = true
            navView.topAnchor.constraint(equalTo: spinner.topAnchor).isActive = true
            navView.rightAnchor.constraint(equalTo: spinner.rightAnchor).isActive = true
            navView.bottomAnchor.constraint(equalTo: spinner.bottomAnchor).isActive = true
            UIView.animate(withDuration: 0.15, animations: {
                self.spinner.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.15, animations: {
                self.spinner.alpha = 0
            }, completion: { _ in
                self.spinner.removeConstraints(self.spinner.constraints)
                self.spinner.removeFromSuperview()
            })
        }
    }
    
    @IBAction private func unwindToEditStudent(segue: UIStoryboardSegue) { }
}

// UIViewController methods
extension EditStudentController {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = .white
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            nameField.becomeFirstResponder()
        case 1:
            performSegue(withIdentifier: "SelectInstitution", sender: nil)
        case 2:
            numberPlateField.becomeFirstResponder()
        default:
            break
        }
    }
}

// UIViewController methods
extension EditStudentController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .appDarkBlue
        
        if !Student.current.isSaved {
            navigationItem.title = NSLocalizedString("EditStudentController.viewDidLoad.navigationItemTitle", value: "Sign Up", comment: "Title for sign up")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let student = Student.current
        nameField.text = student.name
        institutionField.text = student.institution?.name
        numberPlateField.text = student.numberPlate
    }
}

// UITextFieldDelegate methods
extension EditStudentController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            performSegue(withIdentifier: "SelectInstitution", sender: nil)
        case numberPlateField:
            doneButtonPressed()
        default:
            break
        }
        return false
    }
}

extension EditStudentController {
    
    private class FinishSaveStudentOperation: Operation {
        
        private weak var controller: EditStudentController?
        private let saveStudentOperation = Student.current.saveOperation()
        
        init(controller: EditStudentController) {
            super.init()
            self.controller = controller
            addDependency(saveStudentOperation)
            OperationQueue.main.addOperation(self)
        }
        
        override func main() {
            guard let controller = controller else {
                return
            }
            do {
                try saveStudentOperation.checkError()
                controller.performSegue(withIdentifier: "UnwindToRoot", sender: nil)
            } catch {
                controller.setLoadingLayout(false)
                // TODO: Handle error
                print(error)
            }
        }
    }
}

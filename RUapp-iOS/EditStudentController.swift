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
    
    private weak var finishSaveStudentOperation: FinishSaveStudentOperation?
    
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
        setLoadingLayout(true)
        
        finishSaveStudentOperation = FinishSaveStudentOperation()
    }
    
    private func setLoadingLayout(_ loading: Bool) {
//        navigationItem.leftBarButtonItem?.isEnabled = !loading
//        navigationItem.rightBarButtonItem?.isEnabled = !loading
//        UIView.animate(withDuration: 0.2) { [weak self] in
//            self?.loadingView.alpha = loading ? 1 : 0
//        }
    }
    
    @IBAction private func unwindToEditStudent(segue: UIStoryboardSegue) { }
}

// UIViewController methods
extension EditStudentController {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.font = .appTableSectionHeader
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
        
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont.appBarItemDone], for: [.normal, .disabled])
        tableView.backgroundColor = .appDarkBlue
        [nameField, institutionField, numberPlateField].forEach { $0?.font = .appBody }
        
        if !Student.current.isSaved {
            navigationItem.leftBarButtonItems = nil
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
        
        private let saveStudentOperation = Student.current.saveOperation()
        
        override init() {
            super.init()
            addDependency(saveStudentOperation)
            OperationQueue.main.addOperation(self)
        }
        
        override func main() {
            do {
                try saveStudentOperation.persist()
                print("done")
            } catch {
                print(error)
            }
        }
    }
}

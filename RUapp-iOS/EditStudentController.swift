//
//  EditStudentController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import UIKit
import RUappShared

class EditStudentController: UITableViewController {
    
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var numberPlateField: UITextField!
    private weak var loadingController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let student = Student.shared {
            nameField.text = student.name
            numberPlateField.text = student.numberPlate
        } else {
            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.title = NSLocalizedString("EditStudentController.viewDidLoad.navigationItemTitle", value: "Sign Up", comment: "Title for sign up")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameField.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "LoadingScreen"?:
            loadingController = segue.destination
        default:
            break
        }
    }
    
    @IBAction private func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    @IBAction private func doneButtonPressed() {
        guard let name = nameField.text, name.count > 0 else {
            nameField.becomeFirstResponder()
            return
        }
        let numberPlate = numberPlateField.text ?? ""
        view.endEditing(true)
        performSegue(withIdentifier: "LoadingScreen", sender: nil)
        let process = { [weak self] (result: () throws -> Any) in
            do {
                _ = try result()
                DispatchQueue.main.async {
                    self?.loadingController?.performSegue(withIdentifier: "UnwindToRoot", sender: nil)
                }
            } catch {
                let registerErrorAlertTitle = NSLocalizedString("EditStudentController.doneButtonPressed.registerErrorAlertTitle", value: "Error", comment: "Alert title to register error")
                let registerErrorAlertBtn = NSLocalizedString("EditStudentController.doneButtonPressed.registerErrorAlertBtn", value: "OK", comment: "Button to dismiss the alert to register error")
                let alert = UIAlertController(title: registerErrorAlertTitle, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: registerErrorAlertBtn, style: .default) { (_) in
                    self?.loadingController?.dismiss(animated: true)
                })
                self?.loadingController?.present(alert, animated: true)
            }
        }
        if let student = Student.shared {
            student.name = name
            student.numberPlate = numberPlate
            try! student.save() { (result) in
                process(result)
            }
        } else {
            Student.register(name: name, numberPlate: numberPlate) { (result) in
                process(result)
            }
        }
    }
    
    @IBAction private func nameFieldEdited() {
        navigationItem.rightBarButtonItem?.isEnabled = (nameField.text?.count ?? 0) > 0
    }
    
    @IBAction private func unwindToEditStudent(segue: UIStoryboardSegue) { }
}

extension EditStudentController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            numberPlateField.becomeFirstResponder()
        case numberPlateField:
            doneButtonPressed()
        default:
            break
        }
        return false
    }
}

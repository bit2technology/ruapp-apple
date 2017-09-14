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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Student.shared == nil {
            navigationItem.leftBarButtonItems = nil
            navigationItem.title = NSLocalizedString("EditStudentController.viewDidLoad.navigationItemTitle", value: "Sign Up", comment: "Title for sign up")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameField.becomeFirstResponder()
    }
    
    @IBAction private func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    @IBAction private func doneButtonPressed() {
        guard let name = nameField.text, name.count > 0 else {
            let missingNameAlertTitle = NSLocalizedString("EditStudentController.doneButtonPressed.missingNameAlertTitle", value: "Name missing", comment: "Alert title to a missing name value")
            let missingNameAlertBtn = NSLocalizedString("EditStudentController.doneButtonPressed.missingNameAlertBtn", value: "OK", comment: "Button to dismiss the alert to a missing name value")
            let alert = UIAlertController(title: missingNameAlertTitle, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: missingNameAlertBtn, style: .default))
            present(alert, animated: true)
            return
        }
        updateLayout(active: false)
        Student.register(name: name, numberPlate: numberPlateField.text ?? "") { [weak self] (result) in
            do {
                _ = try result()
                self?.dismiss(animated: true)
            } catch {
                self?.updateLayout(active: true)
                let registerErrorAlertTitle = NSLocalizedString("EditStudentController.doneButtonPressed.registerErrorAlertTitle", value: "Error", comment: "Alert title to register error")
                let registerErrorAlertBtn = NSLocalizedString("EditStudentController.doneButtonPressed.registerErrorAlertBtn", value: "OK", comment: "Button to dismiss the alert to register error")
                let alert = UIAlertController(title: registerErrorAlertTitle, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: registerErrorAlertBtn, style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    private func updateLayout(active: Bool) {
        nameField.isEnabled = active
        numberPlateField.isEnabled = active
        navigationItem.leftBarButtonItem?.isEnabled = active
        navigationItem.rightBarButtonItem?.isEnabled = active
    }
}

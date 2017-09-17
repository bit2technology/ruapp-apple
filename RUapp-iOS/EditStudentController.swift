//
//  EditStudentController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import UIKit
import RUappShared

class EditStudentController: UIViewController {
    
    private weak var tableController: EditStudentTableController! {
        didSet {
            tableController.container = self
        }
    }
    
    private var nameField: UITextField {
        return tableController.nameField
    }
    
    private var numberPlateField: UITextField {
        return tableController.numberPlateField
    }
    
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    
    @IBAction func cancelButtonPressed() {
        view.endEditing(true)
        performSegue(withIdentifier: "UnwindToRoot", sender: nil)
    }
    
    @IBAction func doneButtonPressed() {
        guard let name = nameField.text, name.count > 0, let numberPlate = numberPlateField.text, numberPlate.count > 0, let institution = tableController.institution else {
            let missingValuesAlertTitle = NSLocalizedString("EditStudentController.doneButtonPressed.missingValuesAlertTitle", value: "Missing Values", comment: "Alert title to missing values")
            let missingValuesAlertMessage = NSLocalizedString("EditStudentController.doneButtonPressed.missingValuesAlertMessage", value: "Both name and number plate are required", comment: "Alert message to missing values")
            let missingValuesAlertBtn = NSLocalizedString("EditStudentController.doneButtonPressed.missingValuesAlertBtn", value: "OK", comment: "Button to dismiss the alert to missing values")
            let alert = UIAlertController(title: missingValuesAlertTitle, message: missingValuesAlertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: missingValuesAlertBtn, style: .default))
            alert.view.tintColor = .appDarkBlue
            present(alert, animated: true)
            return
        }
        view.endEditing(true)
        setLoadingLayout(true)
        let process = { [weak self] (result: () throws -> Any) in
            do {
                _ = try result()
                self?.performSegue(withIdentifier: "UnwindToRoot", sender: nil)
            } catch {
                DispatchQueue.main.async {
                    self?.setLoadingLayout(false)
                }
                let registerErrorAlertTitle = NSLocalizedString("EditStudentController.doneButtonPressed.registerErrorAlertTitle", value: "Error", comment: "Alert title to register error")
                let registerErrorAlertBtn = NSLocalizedString("EditStudentController.doneButtonPressed.registerErrorAlertBtn", value: "OK", comment: "Button to dismiss the alert to register error")
                let alert = UIAlertController(title: registerErrorAlertTitle, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: registerErrorAlertBtn, style: .default))
                alert.view.tintColor = .appDarkBlue
                self?.present(alert, animated: true)
            }
        }
        if let student = Student.shared {
            student.name = name
            student.numberPlate = numberPlate
            try! student.save() { (result) in
                process(result)
            }
        } else {
            Student.register(name: name, numberPlate: numberPlate, on: institution) { (result) in
                process(result)
            }
        }
    }
    
    private func setLoadingLayout(_ loading: Bool) {
        navigationItem.leftBarButtonItem?.isEnabled = !loading
        navigationItem.rightBarButtonItem?.isEnabled = !loading
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.loadingView.alpha = loading ? 1 : 0
        }
    }
    
    @IBAction private func unwindToEditStudent(segue: UIStoryboardSegue) { }
}

extension EditStudentController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont.appBarItemDone], for: .normal)
        tableController.tableView.backgroundColor = .appDarkBlue
        if let student = Student.shared {
            nameField.text = student.name
            numberPlateField.text = student.numberPlate
        } else {
            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.title = NSLocalizedString("EditStudentController.viewDidLoad.navigationItemTitle", value: "Sign Up", comment: "Title for sign up")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "TableController"?:
            tableController = segue.destination as! EditStudentTableController
        default:
            break
        }
    }
}

class EditStudentTableController: UITableViewController {
    
    private(set) var institution: Institution.Overview?
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberPlateField: UITextField!
    weak var container: EditStudentController!
    
    @IBAction private func fieldEdited() {
        let nameFieldNotEmpty = (nameField.text?.count ?? 0) > 0
        let numberPlateFieldNotEmpty = (numberPlateField.text?.count ?? 0) > 0
        container.navigationItem.rightBarButtonItem?.isEnabled = nameFieldNotEmpty && (institution != nil) && numberPlateFieldNotEmpty
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let idxPth = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: idxPth, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "SelectInstitution"?:
            view.endEditing(true)
        default:
            break
        }
    }
}

extension EditStudentTableController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            performSegue(withIdentifier: "SelectInstitution", sender: nil)
        case numberPlateField:
            container.doneButtonPressed()
        default:
            break
        }
        return false
    }
}

class InstitutionSelectorController: UITableViewController {
    
    private var list: [Institution.Overview]?
    private var downloading = false
    private var error: Error?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    private func getList() {
        guard downloading == false else {
            return
        }
        downloading = true
        error = nil
        updateView()
        Institution.getList { [weak self] (result) in
            self?.downloading = false
            do {
                self?.list = try result()
            } catch {
                self?.error = error
            }
            self?.updateView()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if downloading {
            return 1
        }
        return list?.count ?? 0
    }
    
    private func updateView() {
        
    }
}

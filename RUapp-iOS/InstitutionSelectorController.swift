//
//  InstitutionSelectorController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import UIKit
import RUappShared

class InstitutionSelectorController: UITableViewController {
    
    var editStudentTableController: EditStudentTableController!
    private var list: [Institution.Overview]?
    private var error: Error?
    
    @IBAction func refreshRequested() {
        error = nil
        Institution.getList { [weak self] (result) in
            do {
                self?.list = try result()
                self?.error = nil
            } catch {
                self?.error = error
            }
            DispatchQueue.main.async {
                self?.refreshControl!.endRefreshing()
                self?.updateView()
            }
        }
    }
    
    private func updateView() {
        if let error = error, list == nil {
            let label = UILabel(frame: .zero)
            label.text = error.localizedDescription
            label.textColor = .appRed
            tableView.backgroundView = label
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

// UITableViewController methods
extension InstitutionSelectorController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstitutionCell", for: indexPath)
        let institution = list![indexPath.row]
        cell.textLabel?.text = institution.name
        cell.textLabel?.font = .appBody
        cell.accessoryType = editStudentTableController.institution?.id == institution.id ? .checkmark : .none
        return cell
    }
}

// UIViewController methods
extension InstitutionSelectorController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.beginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshRequested()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "InstitutionSelected"?:
            editStudentTableController.institution = list![tableView.indexPathForSelectedRow!.row]
        default:
            break
        }
    }
}

//
//  InstitutionSelectorController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import RUappShared

class InstitutionSelectorController: UITableViewController {
    
    private var list: [Institution]?
    private weak var refreshOperation: RefreshOperation?
    
    @IBAction func refreshRequested() {
        refreshOperation = RefreshOperation(controller: self)
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
        cell.accessoryType = Student.current.institution == institution ? .checkmark : .none
        return cell
    }
}

// UIViewController methods
extension InstitutionSelectorController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl!.beginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshRequested()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "InstitutionSelected"?:
            Student.current.institution = list![tableView.indexPathForSelectedRow!.row]
        default:
            break
        }
    }
}

extension InstitutionSelectorController {
    
    private class RefreshOperation: Operation {
        
        private weak var controller: InstitutionSelectorController?
        private let updateInstitutionsListOperation = UpdateInstitutionListOperation()
        
        init(controller: InstitutionSelectorController) {
            self.controller = controller
            super.init()
            addDependency(updateInstitutionsListOperation)
            OperationQueue.main.addOperation(self)
        }
        
        override func main() {
            guard let institutionSelectorController = controller else {
                return
            }
            do {
                institutionSelectorController.list = try updateInstitutionsListOperation.parse()
                institutionSelectorController.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            } catch {
                // TODO: Handle error
                fatalError(error.localizedDescription)
            }
            institutionSelectorController.refreshControl!.endRefreshing()
        }
    }
}

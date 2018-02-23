//
//  InstitutionSelectorController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import UIKit
import RUappShared
import CoreData

class InstitutionSelectorController: UITableViewController {

  private weak var finiOp: FinishUpdateInstitutionListOperation?
  private let reqCont: NSFetchedResultsController<Institution> = {
    let req: NSFetchRequest<Institution> = Institution.fetchRequest()
    req.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
    return NSFetchedResultsController(fetchRequest: req, managedObjectContext: PersistentContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: "ListInstitutions")
  }()

  @IBAction func refreshRequested() {
    finiOp = FinishUpdateInstitutionListOperation(controller: self)
  }
}

// UITableViewController methods
extension InstitutionSelectorController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reqCont.sections![section].numberOfObjects
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InstitutionCell", for: indexPath)
    let institution = reqCont.object(at: indexPath)
    cell.textLabel?.text = institution.name
    //        cell.accessoryType = Student.current.institution == institution ? .checkmark : .none
    return cell
  }
}

// UIViewController methods
extension InstitutionSelectorController {

  override func viewDidLoad() {
    super.viewDidLoad()
    reqCont.delegate = self
    do {
      try reqCont.performFetch()
    } catch {
      fatalError(error.localizedDescription)
    }
    refreshControl!.beginRefreshing()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    refreshRequested()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
      //        case "InstitutionSelected"?:
    //            Student.current.institution = reqCont.object(at: tableView.indexPathForSelectedRow!)
    default:
      break
    }
  }
}

extension InstitutionSelectorController: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    case .move:
      tableView.moveRow(at: indexPath!, to: newIndexPath!)
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .automatic)
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}

extension InstitutionSelectorController {

  private class FinishUpdateInstitutionListOperation: Operation {

    private weak var controller: InstitutionSelectorController?
    private let instListOp = UpdateInstitutionListOperation(context: PersistentContainer.shared.viewContext)

    init(controller: InstitutionSelectorController) {
      self.controller = controller
      super.init()
      addDependency(instListOp)
      OperationQueue.main.addOperation(self)
    }

    override func main() {
      guard let controller = controller else {
        return
      }
      controller.refreshControl!.endRefreshing()
    }
  }
}

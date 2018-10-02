import UIKit
import CoreData
import RUappCore

class MenuTableViewController: UITableViewController {
    
    lazy var fetchedResultsController = fetchedResultControllerForToday()
    
    func fetchedResultControllerForToday() -> NSFetchedResultsController<Meal> {
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.propertiesToFetch = ["name", "dishes"]
        request.sortDescriptors = [NSSortDescriptor(key: "open", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: NSPersistentContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! fetchedResultsController.performFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MenuService.updateMenu(restaurantId: 1, context: NSPersistentContainer.shared.newBackgroundContextForUpdate()) { (error) in
            print("menu updated", error)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.object(at: IndexPath(row: section, section: 0)).dishes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.object(at: IndexPath(row: section, section: 0)).name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dish = fetchedResultsController.object(at: IndexPath(row: indexPath.section, section: 0)).dishes![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath)
        cell.textLabel?.text = dish.type
        cell.detailTextLabel?.text = dish.name
        return cell
    }
}

extension MenuTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: indexPath!.row), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: newIndexPath!.row), with: .automatic)
        case .move:
            tableView.moveSection(indexPath!.row, toSection: newIndexPath!.row)
        case .update:
            tableView.reloadSections(IndexSet(integer: indexPath!.row), with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

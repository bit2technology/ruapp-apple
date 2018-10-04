import UIKit
import CoreData
import RUappCore

class MenuTableViewController: UITableViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    lazy var fetchedResultsController = paginatorController.fetchedResultsController
    
    let paginatorController = MenuPaginatorController(context: PersistentContainer.shared.viewContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! fetchedResultsController.performFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let context = PersistentContainer.shared.newBackgroundContextForUpdate()
        MenuService.updateMenu(restaurantId: 1, context: context) { [weak self] (error) in
            guard let strongSelf = self else { return }
            if strongSelf.paginatorController.update() {
                DispatchQueue.main.async {
                    strongSelf.updateFetchedResultsController()
                }
            }
        }
    }
    
    var tableViewAnimation = UITableView.RowAnimation.automatic
    
    func updateFetchedResultsController() {
        let oldSectionsCount = fetchedResultsController.fetchedObjects?.count ?? 0
        fetchedResultsController = paginatorController.fetchedResultsController
        try! fetchedResultsController.performFetch()
        let sectionsCount = fetchedResultsController.fetchedObjects?.count ?? 0
        let reloadSections = min(sectionsCount, oldSectionsCount)
        let insertDeleteSections = max(sectionsCount, oldSectionsCount)
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integersIn: 0..<reloadSections), with: tableViewAnimation)
        if sectionsCount > oldSectionsCount {
            tableView.insertSections(IndexSet(integersIn: reloadSections..<insertDeleteSections), with: tableViewAnimation)
        } else {
            tableView.deleteSections(IndexSet(integersIn: reloadSections..<insertDeleteSections), with: tableViewAnimation)
        }
        tableView.endUpdates()
        navigationItem.title = paginatorController.pageLimits[paginatorController.selectedPage].description
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
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        cell.textLabel?.text = dish.type
        cell.textLabel?.textColor = .darkText
        cell.textLabel?.font = bodyFont
        cell.detailTextLabel?.text = dish.name
        cell.detailTextLabel?.textColor = .darkGray
        cell.detailTextLabel?.font = bodyFont
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

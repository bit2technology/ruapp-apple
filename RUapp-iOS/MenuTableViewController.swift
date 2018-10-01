import UIKit
import CoreData
import RUappCore

class MenuTableViewController: UITableViewController {
    
    lazy var fetchedResultsController = fetchedResultControllerForToday()
    
    func fetchedResultControllerForToday() -> NSFetchedResultsController<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>()
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: NSPersistentContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }
}

extension MenuTableViewController: NSFetchedResultsControllerDelegate {
    
}

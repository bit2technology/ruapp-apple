//
//  MenuController.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 16/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import RUappShared
import CoreData
import Bit2Common

class MenuController: UITableViewController {
    
    
    
    
    
    
    let op = OtherOperation()
    
    
    
    
    
    
    
    private func skipDaysAndAnimate(_ days: Int) {

        assert(days != 0, "'days' can't be equal to zero")
        
        tableView.beginUpdates()
        if let oldSectionsCount = fetchedResultsController.sections?.count, oldSectionsCount > 0 {
            tableView.deleteSections(IndexSet(integersIn: 0..<oldSectionsCount), with: days > 0 ? .left : .right)
        }
        timeBounds.skip(days: days)
        if let newSectionsCount = fetchedResultsController.sections?.count, newSectionsCount > 0 {
            tableView.insertSections(IndexSet(integersIn: 0..<newSectionsCount), with: days > 0 ? .right : .left)
        }
        tableView.endUpdates()
    }
    
    @IBAction private func leftArrowTap() {
        skipDaysAndAnimate(-1)
    }
    @IBAction private func rightArrowTap() {
        skipDaysAndAnimate(1)
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    private var timeBounds = TimeBounds() {
        didSet {
            navigationItem.title = dateFormatter.string(from: timeBounds.start)
            fetchedResultsController = fetchedResultsControllerForCurrentTimeBounds()
        }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<Dish>! {
        didSet {
            fetchedResultsController.delegate = self
            try! fetchedResultsController.performFetch()
        }
    }
    
    func fetchedResultsControllerForCurrentTimeBounds() -> NSFetchedResultsController<Dish> {
        let req = Dish.request()
        req.predicate = NSPredicate(format: "meal.open < %@ AND meal.close >= %@", timeBounds.finish as NSDate, timeBounds.start as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "meal.open", ascending: true), NSSortDescriptor(key: "order", ascending: true)]
        return NSFetchedResultsController(fetchRequest: req, managedObjectContext: CoreDataContainer.shared.viewContext, sectionNameKeyPath: "meal.open", cacheName: nil)
    }
}

extension MenuController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (fetchedResultsController.sections?[section].objects?.first as? Dish)?.meal?.name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath)
        let dish = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = dish.type
        cell.detailTextLabel?.text = dish.name ?? "Lorem ipsum dolor sit amet"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeBounds.today()
    }
}

extension MenuController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
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

private struct TimeBounds {
    var start: Date
    var finish: Date
    
    init() {
        start = Date()
        finish = start
    }
    
    mutating func today() {
        
        let now = Date()
        let midnight = DateComponents(hour: 0, minute: 0, nanosecond: 0)
        let oneDayBefore = DateComponents(day: -1)
        let gregorianCalendar = Calendar(identifier: .gregorian)
        
        if let midnightTodayToTomorrow = gregorianCalendar.nextDate(after: now, matching: midnight, matchingPolicy: .nextTime), let midnightYesterdayToToday = gregorianCalendar.date(byAdding: oneDayBefore, to: midnightTodayToTomorrow) {
            start = midnightYesterdayToToday
            finish = midnightTodayToTomorrow
        } else {
            finish.addTimeInterval(86400) // 24h
        }
    }
    
    mutating func skip(days: Int) {
        
        let daysComponents = DateComponents(day: days)
        let gregorianCalendar = Calendar(identifier: .gregorian)
        
        guard let newStart = gregorianCalendar.date(byAdding: daysComponents, to: start), let newFinish = gregorianCalendar.date(byAdding: daysComponents, to: finish) else {
            let daysInterval = TimeInterval(days * 86400)
            start.addTimeInterval(daysInterval)
            finish.addTimeInterval(daysInterval)
            return
        }
        
        start = newStart
        finish = newFinish
    }
}

class OtherOperation: Operation {
    
    let op = UpdateMenuOperation(restaurantId: 1)
    
    override init() {
        super.init()
        addDependency(op)
        OperationQueue.main.addOperation(self)
    }
    
    override func main() {
//        do { try print(op.parse()) } catch { print(error) }
    }
}

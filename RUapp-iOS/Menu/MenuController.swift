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
        
        let bef = Date()
        
        tableView.beginUpdates()
        if let oldSectionsCount = fetchedResultsController.sections?.count, oldSectionsCount > 0 {
            tableView.deleteSections(IndexSet(integersIn: 0..<oldSectionsCount), with: days > 0 ? .left : .right)
        }
        timeBounds.skip(days: days)
        if let newSectionsCount = fetchedResultsController.sections?.count, newSectionsCount > 0 {
            tableView.insertSections(IndexSet(integersIn: 0..<newSectionsCount), with: days > 0 ? .right : .left)
        }
        tableView.endUpdates()
        
        print(Date().timeIntervalSince(bef))
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
    
    private var fetchedResultsController: NSFetchedResultsController<Meal>! {
        didSet {
            fetchedResultsController.delegate = self
            try! fetchedResultsController.performFetch()
            
            let gregorianCalendar = Calendar(identifier: .gregorian)
            let numberOfRows = fetchedResultsController.sections?.first?.numberOfObjects ?? 0
            tableMetadata = (0..<numberOfRows).map {
                
                let meal = fetchedResultsController.object(at: IndexPath(row: $0, section: 0))
                var metadata = (meal.name?.localizedUppercase, UIColor.darkGray)
                
                guard let openDate = meal.open else {
                    return metadata
                }
                
                switch gregorianCalendar.component(.hour, from: openDate) {
                case 5..<10:
                    metadata.1 = #colorLiteral(red: 0.9254901961, green: 0.5450980392, blue: 0.4156862745, alpha: 1)
                case 10..<15:
                    metadata.1 = #colorLiteral(red: 0.7882352941, green: 0.3058823529, blue: 0.3725490196, alpha: 1)
                case 0..<5, 15..<24:
                    metadata.1 = #colorLiteral(red: 0.4588235294, green: 0.2156862745, blue: 0.3803921569, alpha: 1)
                default:
                    break
                }
                return metadata
            }
        }
    }
    
    private var tableMetadata: [(title: String?, backgroundColor: UIColor)]?
    
    private func fetchedResultsControllerForCurrentTimeBounds() -> NSFetchedResultsController<Meal> {
        let req = Meal.request()
        req.predicate = NSPredicate(format: "open < %@ AND close >= %@", timeBounds.finish as NSDate, timeBounds.start as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "open", ascending: true)]
        return NSFetchedResultsController(fetchRequest: req, managedObjectContext: CoreDataContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
}

extension MenuController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealCell
        let meal = fetchedResultsController.object(at: indexPath)
        let metadata = tableMetadata?[indexPath.row]
        cell.name.text = metadata?.title
        cell.name.backgroundColor = metadata?.backgroundColor
        cell.numberOfDishes = meal.dishes?.count ?? 0
        meal.dishes?.enumerated().forEach {
            let dish = $0.element as! Dish
            let row = cell.dishRow(at: $0.offset)
            row.type.text = dish.type
            row.type.backgroundColor = metadata?.backgroundColor
            row.name.text = dish.name ?? "Lorem ipsum dolor sit amet"
            row.name.backgroundColor = metadata?.backgroundColor
        }
        cell.tintColor = metadata?.backgroundColor
        cell.applyLayout()
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeBounds.today()
//        tableView.backgroundColor = .white
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

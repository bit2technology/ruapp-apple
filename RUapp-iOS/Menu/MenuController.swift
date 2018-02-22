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

    private weak var op: FinishUpdateMenuOperation?

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

    @IBAction private func updateMenu() {
        guard self.op == nil else { return }
        let op = FinishUpdateMenuOperation()
        op.menuController = self
        self.op = op
        OperationQueue.main.addOperation(op)
    }

    @IBAction private func leftArrowTap() {
        skipDaysAndAnimate(-1)
    }
    @IBAction private func rightArrowTap() {
        skipDaysAndAnimate(1)
    }

    private var navTitleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private var timeBounds = TimeBounds() {
        didSet {
            navigationItem.title = navTitleDateFormatter.string(from: timeBounds.start)
            fetchedResultsController = fetchedResultsControllerForCurrentTimeBounds()
        }
    }

    private var tableMetadata: [(title: String, backgroundColor: UIColor)] = []

    private func updateTableMetadata() {

        let gregorianCalendar = Calendar(identifier: .gregorian)
        let numberOfRows = fetchedResultsController.sections?.first?.numberOfObjects ?? 0
        tableMetadata = (0..<numberOfRows).map {
            let meal = fetchedResultsController.object(at: IndexPath(row: $0, section: 0))

            let color: UIColor
            switch gregorianCalendar.component(.hour, from: meal.open!) {
            case 5..<10:
                color = #colorLiteral(red: 0.9254901961, green: 0.5450980392, blue: 0.4156862745, alpha: 1)
            case 10..<15:
                color = #colorLiteral(red: 0.7882352941, green: 0.3058823529, blue: 0.3725490196, alpha: 1)
            default:
                color = #colorLiteral(red: 0.4588235294, green: 0.2156862745, blue: 0.3803921569, alpha: 1)
            }

            return (meal.name!.localizedUppercase, color)
        }
    }

    private var fetchedResultsController: NSFetchedResultsController<Meal>! {
        didSet {
            fetchedResultsController.delegate = self
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError(error.localizedDescription)
            }
            updateTableMetadata()
        }
    }

    private func fetchedResultsControllerForCurrentTimeBounds() -> NSFetchedResultsController<Meal> {
        let req = Meal.request()
        req.predicate = NSPredicate(format: "open < %@ AND close >= %@", timeBounds.finish as NSDate, timeBounds.start as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "open", ascending: true)]
        return NSFetchedResultsController(fetchRequest: req, managedObjectContext: CoreDataContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    private func updateLayout(for traitCollection: UITraitCollection) {
        if traitCollection.verticalSizeClass == .regular, #available(iOS 11.0, *) {
            refreshControl!.tintColor = .white
        } else {
            refreshControl!.tintColor = .gray
        }
    }
}

extension MenuController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meal = fetchedResultsController.object(at: indexPath)
        let metadata = tableMetadata[indexPath.row]

        guard let dishes = meal.dishes, dishes.count > 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MealMetaCell", for: indexPath) as! MealMetaCell
            cell.name.text = metadata.title
            cell.name.backgroundColor = metadata.backgroundColor
            cell.tintColor = metadata.backgroundColor
            cell.applyLayout()
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealCell
        cell.name.text = metadata.title
        cell.name.backgroundColor = metadata.backgroundColor
        cell.numberOfDishes = dishes.count
        dishes.enumerated().forEach {
            let dish = $0.element as! Dish
            let row = cell.dishRow(at: $0.offset)
            row.type.text = dish.type
            row.type.backgroundColor = metadata.backgroundColor
            row.name.text = dish.name
            row.name.backgroundColor = metadata.backgroundColor
        }
        cell.tintColor = metadata.backgroundColor
        cell.applyLayout()
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLayout(for: traitCollection)

        timeBounds.today()
        updateMenu()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        updateLayout(for: newCollection)
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
        updateTableMetadata()
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

private class FinishUpdateMenuOperation: Foundation.Operation {

    let op = UpdateMenuOperation(restaurantId: 1)
    weak var menuController: MenuController?

    override init() {
        super.init()
        addDependency(op)
        OperationQueue.async.addOperation(op)
    }

    override func main() {

        guard let menuController = menuController else {
            return
        }
        menuController.refreshControl?.endRefreshing()

        do {
            let newMeals = try op.value()
            print("updated \(newMeals.count) meals")
        } catch {
            print("update menu failed:", error)
        }
    }
}

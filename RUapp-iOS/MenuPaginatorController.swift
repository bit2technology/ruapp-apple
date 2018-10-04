import CoreData
import RUappCore

class MenuPaginatorController {
    
    var pageCount: Int {
        return pageLimits.count - 1
    }
    
    var selectedPage = 0
    
    private(set) var pageLimits: [Date]
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        let dates = earliestLatestDates(context: context)
        pageLimits = getPageLimits(earliestDate: dates.earliest, latestDate: dates.latest)
    }
    
    var fetchedResultsController: NSFetchedResultsController<Meal> {
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.predicate = NSPredicate(format: "open >= %@ && open < %@", pageLimits[selectedPage] as NSDate, pageLimits[selectedPage + 1] as NSDate)
        request.propertiesToFetch = ["name", "dishes"]
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.open, ascending: true)]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    @discardableResult
    func update() -> Bool {
        let dates = earliestLatestDates(context: context)
        return update(earliestDate: dates.earliest, latestDate: dates.latest)
    }
    
    @discardableResult
    func update(earliestDate: Date, latestDate: Date) -> Bool {
        let oldPageLimits = pageLimits
        pageLimits = getPageLimits(earliestDate: earliestDate, latestDate: latestDate)
        return pageLimits != oldPageLimits
    }
}

func earliestLatestDates(context: NSManagedObjectContext) -> (earliest: Date, latest: Date) {
    let req: NSFetchRequest<Meal> = Meal.fetchRequest()
    req.fetchLimit = 1
    req.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.open, ascending: true)]
    let earliestOpenDate = (try? context.fetch(req))?.first?.open ?? Date()
    req.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.open, ascending: false)]
    let latestOpenDate = (try? context.fetch(req))?.first?.open ?? Date()
    return (earliestOpenDate, latestOpenDate)
}

func getPageLimits(earliestDate: Date, latestDate: Date, calendar: Calendar = .current, timeZone: TimeZone = .current) -> [Date] {
    var pageLimits: [Date] = []
    let midnight = DateComponents(timeZone: timeZone, hour: 0, minute: 0, second: 0, nanosecond: 0)
    pageLimits.append(calendar.nextDate(after: earliestDate, matching: midnight, matchingPolicy: .strict, repeatedTimePolicy: .last, direction: .backward)!)
    while pageLimits.last! < latestDate {
        pageLimits.append(calendar.nextDate(after: pageLimits.last!, matching: midnight, matchingPolicy: .strict, repeatedTimePolicy: .last, direction: .forward)!)
    }
    return pageLimits
}

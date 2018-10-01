import CoreData

public final class MenuService {
    
    public static func updateMenu(restaurantId: Int, context: NSManagedObjectContext, completionHandler: @escaping (Error?) -> Void) {
        // Get menu data.
        let url = URL(string: "https://www.ruapp.com.br/api/v2/menu?restaurant_id=\(restaurantId)")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Check for error.
            if let error = error {
                completionHandler(error)
                return
            }
            // Persist new data and delete old ones.
            context.perform {
                do {
                    _ = try JSONDecoder(context: context).decode([Meal].self, from: data!)
                    // Delete old dishes.
                    let dishesFetchRequest: NSFetchRequest<Dish> = Dish.fetchRequest()
                    dishesFetchRequest.predicate = NSPredicate(format: "meal == nil")
                    try context.fetch(dishesFetchRequest).forEach(context.delete)
                    // Delete old votables.
                    let votablesFetchRequest: NSFetchRequest<Votable> = Votable.fetchRequest()
                    votablesFetchRequest.predicate = NSPredicate(format: "meal == nil")
                    try context.fetch(votablesFetchRequest).forEach(context.delete)
                    // Finish task.
                    completionHandler(nil)
                } catch {
                    completionHandler(error)
                    return
                }
            }
        }
    }
}

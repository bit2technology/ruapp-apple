import CoreData

public final class MenuService {
    
    public static func updateMenu(restaurantId: Int, context: NSManagedObjectContext, completionHandler: @escaping (Error?) -> Void) {
        let url = URL(string: "https://www.ruapp.com.br/api/v2/menu?restaurant_id=\(restaurantId)")!
        updateMenu(request: URLRequest(url: url), context: context, completionHandler: completionHandler)
    }
    
    static func updateMenu(request: URLRequest, context: NSManagedObjectContext, completionHandler: @escaping (Error?) -> Void) {
        // Get menu data.
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for error.
            if let error = error {
                completionHandler(error)
                return
            }
            // Persist new data.
            context.perform {
                do {
                    _ = try JSONDecoder(context: context).decode([Meal].self, from: data!)
                    try context.save()
                    completionHandler(nil)
                } catch {
                    completionHandler(error)
                    return
                }
            }
        }
        task.resume()
    }
}

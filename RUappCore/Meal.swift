import CoreData

public final class Meal: NSManagedObject, Decodable {
    
    public convenience init(from decoder: Decoder) throws {
        self.init(context: decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        meta = try container.decode(String.self, forKey: .meta)
        open = try container.decode(Date.self, forKey: .open)
        close = try container.decode(Date.self, forKey: .close)
        dishes = NSOrderedSet(array: try container.decode([Dish].self, forKey: .dishes))
        votables = NSOrderedSet(array: try container.decode([Votable].self, forKey: .votables))
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case meta
        case open
        case close
        case dishes
        case votables
    }
}

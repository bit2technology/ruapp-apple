import CoreData

public final class Dish: NSManagedObject, Decodable {
    
    public convenience init(from decoder: Decoder) throws {
        self.init(context: decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        meta = try container.decode(String.self, forKey: .meta)
        name = try? container.decode(String.self, forKey: .name)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case meta
        case name
    }
}

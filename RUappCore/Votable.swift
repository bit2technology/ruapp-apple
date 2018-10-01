import CoreData

public final class Votable: NSManagedObject, Decodable {
    
    public convenience init(from decoder: Decoder) throws {
        self.init(context: decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        meta = try container.decode(String.self, forKey: .meta)
        id = try container.decode(Int64.self, forKey: .id)
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case meta
        case id
    }
}

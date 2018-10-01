import CoreData

class JSONDecoder: Foundation.JSONDecoder {
    init(managedObjectContext: NSManagedObjectContext) {
        super.init()
        userInfo[.managedObjectContext] = managedObjectContext
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "ManagedObjectContext")!
}

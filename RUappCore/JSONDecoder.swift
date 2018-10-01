import CoreData

class JSONDecoder: Foundation.JSONDecoder {
    init(context: NSManagedObjectContext) {
        super.init()
        userInfo[.managedObjectContext] = context
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "ManagedObjectContext")!
}

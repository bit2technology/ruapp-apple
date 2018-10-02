import CoreData

class JSONDecoder: Foundation.JSONDecoder {
    init(context: NSManagedObjectContext) {
        super.init()
        dateDecodingStrategy = .iso8601
        userInfo[.managedObjectContext] = context
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "ManagedObjectContext")!
}

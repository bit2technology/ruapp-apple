import CoreData

public class PersistentContainer: NSPersistentContainer {
    
    public static let shared: PersistentContainer = {
        let modelURL = Bundle(for: PersistentContainer.self).url(forResource: "Model", withExtension: "momd")!
        let container = PersistentContainer(name: "Model", managedObjectModel: NSManagedObjectModel(contentsOf: modelURL)!)
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.technology.bit2.ruapp")!.appendingPathComponent("data.sqlite", isDirectory: false)
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.type = NSSQLiteStoreType
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { (storeDescriptor, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    public func newBackgroundContextForUpdate() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}

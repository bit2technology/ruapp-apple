import RUappCore
import CoreData

extension PersistentContainer {
    static func forTesting() -> PersistentContainer {
        let modelURL = Bundle(for: PersistentContainer.self).url(forResource: "Model", withExtension: "momd")!
        let container = PersistentContainer(name: "Model", managedObjectModel: NSManagedObjectModel(contentsOf: modelURL)!)
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { (storeDescriptor, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
}

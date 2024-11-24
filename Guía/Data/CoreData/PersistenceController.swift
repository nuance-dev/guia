import CoreData
import CloudKit

final class PersistenceController {
    // MARK: - Shared Instance
    static let shared = PersistenceController()
    
    // MARK: - Properties
    let container: NSPersistentContainer
    
    // MARK: - Initialize
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Guia")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure store for future CloudKit sync
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve store description")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - CRUD Operations
    func save() throws {
        try container.viewContext.save()
    }
    
    func delete(_ object: NSManagedObject) throws {
        container.viewContext.delete(object)
        try save()
    }
}
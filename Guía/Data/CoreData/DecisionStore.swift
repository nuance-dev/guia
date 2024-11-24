import CoreData
import Combine

final class DecisionStore {
    // MARK: - Properties
    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    // MARK: - Initialize
    init(persistenceController: PersistenceController) {
        self.viewContext = persistenceController.container.viewContext
        self.backgroundContext = persistenceController.container.newBackgroundContext()
    }
    
    // MARK: - CRUD Operations
    func createDecision(_ decision: Decision) async throws -> NSManagedObjectID {
        try await backgroundContext.perform {
            let entity = DecisionEntity(context: self.backgroundContext)
            entity.configure(with: decision)
            try self.backgroundContext.save()
            return entity.objectID
        }
    }
    
    func fetchDecision(id: NSManagedObjectID) throws -> Decision {
        guard let entity = try viewContext.existingObject(with: id) as? DecisionEntity else {
            throw StoreError.fetchFailed
        }
        return entity.toDomain()
    }
    
    func updateDecision(_ decision: Decision) async throws {
        try await backgroundContext.perform {
            guard let entity = try self.backgroundContext.existingObject(with: decision.id) as? DecisionEntity else {
                throw StoreError.updateFailed
            }
            entity.configure(with: decision)
            try self.backgroundContext.save()
        }
    }
    
    func deleteDecision(id: NSManagedObjectID) async throws {
        try await backgroundContext.perform {
            guard let entity = try self.backgroundContext.existingObject(with: id) as? DecisionEntity else {
                throw StoreError.deleteFailed
            }
            self.backgroundContext.delete(entity)
            try self.backgroundContext.save()
        }
    }
    
    // MARK: - Batch Operations
    func batchDeleteDecisions(before date: Date) async throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DecisionEntity")
        fetchRequest.predicate = NSPredicate(format: "createdAt < %@", date as NSDate)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        try await backgroundContext.perform {
            guard let result = try self.backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult,
                  let objectIDs = result.result as? [NSManagedObjectID] else {
                throw StoreError.batchDeleteFailed
            }
            
            // Sync changes with view context
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                into: [self.viewContext]
            )
        }
    }
    
    func batchUpdateDecisionStatus(ids: [NSManagedObjectID], status: Decision.Status) async throws {
        try await backgroundContext.perform {
            let fetchRequest = NSFetchRequest<DecisionEntity>(entityName: "DecisionEntity")
            fetchRequest.predicate = NSPredicate(format: "SELF IN %@", ids)
            
            let entities = try self.backgroundContext.fetch(fetchRequest)
            entities.forEach { $0.status = status.rawValue }
            
            try self.backgroundContext.save()
        }
    }
}
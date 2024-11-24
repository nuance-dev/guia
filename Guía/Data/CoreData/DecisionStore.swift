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
    
    func updateDecision(_ decision: Decision) async throws
    func deleteDecision(id: NSManagedObjectID) async throws
    
    // MARK: - Batch Operations
    func batchDeleteDecisions(before date: Date) async throws
    func batchUpdateDecisionStatus(ids: [NSManagedObjectID], status: Decision.Status) async throws
}
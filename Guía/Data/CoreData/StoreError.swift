import Foundation

enum StoreError: LocalizedError {
    case fetchFailed
    case updateFailed
    case deleteFailed
    case batchDeleteFailed
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Failed to fetch data"
        case .updateFailed:
            return "Failed to update data"
        case .deleteFailed:
            return "Failed to delete data"
        case .batchDeleteFailed:
            return "Failed to perform batch delete"
        }
    }
} 
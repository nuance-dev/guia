import Foundation
// MARK: - Criterion Model
struct Criterion: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String?
    var importance: Importance // For basic mode
    var weight: Double? // For advanced mode
    var unit: String?
    var created: Date
    var modified: Date
    
    enum Importance: Int, Codable {
        case low = 1
        case medium = 2
        case high = 3
        
        var weightValue: Double {
            switch self {
            case .low: return 0.2
            case .medium: return 0.5
            case .high: return 1.0
            }
        }
    }
    
    // MARK: - Initialize
    init(id: UUID = UUID(),
         name: String,
         description: String? = nil,
         importance: Importance = .medium,
         weight: Double? = nil,
         unit: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.importance = importance
        self.weight = weight
        self.unit = unit
        self.created = Date()
        self.modified = Date()
    }
    
    // MARK: - Helper Methods
    var effectiveWeight: Double {
        weight ?? importance.weightValue
    }
    
    mutating func updateWeight(_ newWeight: Double) {
        weight = max(0, min(1, newWeight))
        modified = Date()
    }
}
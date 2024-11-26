import Foundation

struct BasicCriterion: Criterion, Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String?
    var importance: Importance
    var unit: String?
    var weight: Double { importance.weight }
    
    enum Importance: Int, Codable, CaseIterable {
        case low = 1
        case medium = 2
        case high = 3
        
        var weight: Double {
            switch self {
            case .low: return 0.33
            case .medium: return 0.66
            case .high: return 1.0
            }
        }
    }
    
    init(id: UUID = UUID(), name: String, description: String? = nil, importance: Importance = .medium, unit: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.importance = importance
        self.unit = unit
    }
} 
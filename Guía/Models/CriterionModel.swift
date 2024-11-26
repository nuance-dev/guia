import Foundation

// MARK: - Criterion Protocol
public protocol Criterion: Identifiable, Codable {
    var id: UUID { get }
    var name: String { get set }
    var description: String? { get set }
    var weight: Double { get }
}

// MARK: - Unified Criterion
public struct UnifiedCriterion: Criterion, Codable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var importance: Importance
    public var unit: String?
    public let created: Date
    public var modified: Date
    
    public enum Importance: Int, Codable, CaseIterable {
        case low = 1
        case medium = 2
        case high = 3
        
        public var weight: Double {
            switch self {
            case .low: return 0.33
            case .medium: return 0.66
            case .high: return 1.0
            }
        }
        
        public static func from(weight: Double) -> Importance {
            switch weight {
            case 0.0...0.4: return .low
            case 0.4...0.75: return .medium
            default: return .high
            }
        }
    }
    
    public var weight: Double {
        importance.weight
    }
    
    // MARK: - Initialize
    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        importance: Importance = .medium,
        unit: String? = nil,
        created: Date = Date(),
        modified: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.importance = importance
        self.unit = unit
        self.created = created
        self.modified = modified
    }
    
    // MARK: - Helper Methods
    public mutating func updateWeight(_ newWeight: Double) {
        self.importance = .from(weight: newWeight)
        self.modified = Date()
    }
}

import Foundation

// MARK: - Criterion Protocol
public protocol Criterion: Identifiable, Codable {
    var id: UUID { get }
    var name: String { get set }
    var description: String? { get set }
    var weight: Double { get }
}

// MARK: - Basic Criterion
public struct BasicCriterion: Criterion, Codable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var importance: Importance
    public var unit: String?
    public var created: Date
    public var modified: Date
    
    public enum Importance: Int, Codable, CaseIterable {
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
    
    public var weight: Double {
        importance.weightValue
    }
    
    // MARK: - Initialize
    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        importance: Importance = .medium,
        unit: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.importance = importance
        self.unit = unit
        self.created = Date()
        self.modified = Date()
    }
    
    // MARK: - Helper Methods
    public var effectiveWeight: Double {
        weight
    }
    
    public mutating func updateWeight(_ newWeight: Double) {
        // Convert weight to importance
        let importance: Importance
        switch newWeight {
        case 0.0...0.3: importance = .low
        case 0.3...0.7: importance = .medium
        default: importance = .high
        }
        self.importance = importance
        modified = Date()
    }
}

// MARK: - Advanced Criterion
public struct AdvancedCriterion: Criterion {
    public let id: UUID
    public var name: String
    public var description: String?
    private var _weight: Double
    public var unit: String?
    public var created: Date
    public var modified: Date
    
    public var weight: Double {
        get { _weight }
        set { _weight = max(0, min(1, newValue)) }
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        weight: Double = 0.5,
        unit: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self._weight = max(0, min(1, weight))
        self.unit = unit
        self.created = Date()
        self.modified = Date()
    }
}

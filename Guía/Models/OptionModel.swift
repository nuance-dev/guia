import Foundation

public struct Option: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var scores: [UUID: Double]
    public var notes: String?
    public var pros: [String]
    public var cons: [String]
    public var isArchived: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        scores: [UUID: Double] = [:],
        notes: String? = nil,
        pros: [String] = [],
        cons: [String] = [],
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.scores = scores
        self.notes = notes
        self.pros = pros
        self.cons = cons
        self.isArchived = isArchived
    }
    
    // Backward compatibility initializer
    public init(title: String, description: String? = nil, pros: [String] = [], cons: [String] = [], isArchived: Bool = false) {
        self.init(
            name: title,
            description: description,
            pros: pros,
            cons: cons,
            isArchived: isArchived
        )
    }
}

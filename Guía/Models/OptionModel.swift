import Foundation

public struct Option: Identifiable, Codable {
    public let id: UUID
    public var title: String
    public var description: String?
    public var pros: [String]
    public var cons: [String]
    public var isArchived: Bool
    
    public init(id: UUID = UUID(), title: String, description: String? = nil, pros: [String] = [], cons: [String] = [], isArchived: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.pros = pros
        self.cons = cons
        self.isArchived = isArchived
    }
}
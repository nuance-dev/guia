import Foundation

// MARK: - Option Model
struct Option: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String?
    var scores: [UUID: Double] // Criteria ID to score mapping
    var notes: String?
    var created: Date
    var modified: Date
    
    // MARK: - Initialize
    init(id: UUID = UUID(), 
         name: String, 
         description: String? = nil, 
         scores: [UUID: Double] = [:], 
         notes: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.scores = scores
        self.notes = notes
        self.created = Date()
        self.modified = Date()
    }
    
    // MARK: - Helper Methods
    mutating func updateScore(for criterionId: UUID, to value: Double) {
        scores[criterionId] = value
        modified = Date()
    }
    
    func validateScores(against criteria: [Criterion]) -> Bool {
        for criterion in criteria {
            if scores[criterion.id] == nil {
                return false
            }
        }
        return true
    }
}
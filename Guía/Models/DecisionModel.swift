import Foundation

// MARK: - Decision Model
struct Decision: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var options: [Option]
    var criteria: [Criterion]
    var weights: [UUID: Double] // Criteria ID to weight mapping
    var created: Date
    var modified: Date
    
    // MARK: - Analysis Results
    var analysisResults: AnalysisResults?
    
    // MARK: - Helper Methods
    func validateWeights() -> Bool
    func normalizeWeights() -> [UUID: Double]
    
    // MARK: - Analysis Methods
    mutating func calculateResults(using method: AnalysisMethod) async throws
}

// MARK: - Option Model
struct Option: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String?
    var scores: [UUID: Double] // Criteria ID to score mapping
}

// MARK: - Criterion Model
struct Criterion: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String?
    var importance: Importance // For basic mode
    var weight: Double? // For advanced mode
    var unit: String?
    
    enum Importance: Int, Codable {
        case low = 1
        case medium = 2
        case high = 3
    }
}
import Foundation

// MARK: - Analysis Results
struct AnalysisResults: Codable {
    var rankedOptions: [RankedOption]
    var confidenceScore: Double
    var sensitivityData: SensitivityData
    var method: AnalysisMethod
    var criteria: [Criterion]
    
    struct RankedOption: Identifiable, Codable {
        let id: UUID
        let optionId: UUID
        let score: Double
        var rank: Int
        var breakdownByCriteria: [UUID: Double]
        
        private enum CodingKeys: String, CodingKey {
            case id
            case optionId
            case score
            case rank
            case breakdownByCriteria
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case rankedOptions
        case confidenceScore
        case sensitivityData
        case method
        case criteria
    }
}


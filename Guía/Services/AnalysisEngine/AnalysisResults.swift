import Foundation

// MARK: - Analysis Results
struct AnalysisResults: Codable {
    var rankedOptions: [RankedOption]
    var confidenceScore: Double
    var sensitivityData: SensitivityData
    var method: AnalysisMethod
    
    struct RankedOption: Identifiable, Codable {
        let id: UUID
        let optionId: UUID
        let score: Double
        let rank: Int
        var breakdownByCriteria: [UUID: Double]
    }
}


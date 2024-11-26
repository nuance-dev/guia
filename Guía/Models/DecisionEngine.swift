import Foundation

struct Factor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var weight: Double // 0.0 to 1.0
    var score: Double // -1.0 to 1.0
}

struct Option {
    var name: String
    var factors: [Factor]
    var timeframe: TimeFrame
    var riskLevel: RiskLevel
    
    var weightedScore: Double {
        factors.reduce(0) { $0 + ($1.weight * $1.score) }
    }
}

enum TimeFrame: String, CaseIterable {
    case immediate = "Right now"
    case shortTerm = "This week"
    case mediumTerm = "This month"
    case longTerm = "This year"
}

enum RiskLevel: String, CaseIterable {
    case veryLow = "Very Safe"
    case low = "Safe"
    case medium = "Balanced"
    case high = "Risky"
    case veryHigh = "Very Risky"
} 
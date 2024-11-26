import Foundation

struct Factor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var weight: Double // 0.0 to 1.0
    var score: Double // -1.0 to 1.0
    
    var weightedImpact: Double {
        return weight * score
    }
    
    var normalizedScore: Double {
        return (score + 1) / 2 // Convert from -1...1 to 0...1
    }
}

struct Option: Identifiable {
    let id = UUID()
    var name: String
    var factors: [Factor]
    var timeframe: TimeFrame
    var riskLevel: RiskLevel
    
    var weightedScore: Double {
        let totalWeight = factors.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return 0 }
        
        let score = factors.reduce(0) { $0 + $1.weightedImpact } / totalWeight
        return score.isFinite ? score : 0
    }
    
    var confidenceScore: Double {
        guard !factors.isEmpty else { return 0 }
        
        let factorCount = Double(factors.count)
        let averageWeight = factors.reduce(0) { $0 + $1.weight } / factorCount
        let weightVariance = factors.reduce(0) { $0 + pow($1.weight - averageWeight, 2) } / factorCount
        
        // Calculate base confidence (0-100)
        let baseConfidence = (1 - weightVariance) * 100
        
        // Apply factor count bonus (more factors = higher confidence)
        let factorBonus = min(factorCount / 5, 1.0) * 20
        
        // Combine and ensure result is within 0-100
        let finalScore = min(max(baseConfidence + factorBonus, 0), 100)
        return finalScore.isFinite ? finalScore : 0
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
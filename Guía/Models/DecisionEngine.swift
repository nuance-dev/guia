import Foundation

struct Factor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var weight: Double // 0.0 to 1.0
    var score: Double // -1.0 to 1.0
    
    var weightedImpact: Double {
        return weight * normalizedScore
    }
    
    var normalizedScore: Double {
        return (score + 1) / 2 // Convert from -1...1 to 0...1
    }
    
    // Validate weight is between 0 and 1
    mutating func validateWeight() {
        weight = min(max(weight, 0), 1)
    }
}

struct Option: Identifiable {
    let id = UUID()
    var name: String
    var factors: [Factor]
    var timeframe: TimeFrame
    var riskLevel: RiskLevel
    var scores: [UUID: Double] = [:]
    
    var weightedScore: Double {
        let totalWeight = factors.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return 0 }
        
        return factors.reduce(0) { sum, factor in
            sum + (factor.weightedImpact / totalWeight)
        }
    }
    
    var confidenceScore: Double {
        guard !factors.isEmpty else { return 0 }
        
        // Calculate weighted variance of scores
        let avgScore = weightedScore
        let variance = factors.reduce(0) { sum, factor in
            sum + (factor.weight * pow(factor.normalizedScore - avgScore, 2))
        }
        
        // Factor count influence (more factors = higher base confidence)
        let factorCountBonus = min(Double(factors.count) / 5.0, 1.0) * 0.2
        
        // Weight distribution influence
        let weightSpread = calculateWeightSpread()
        
        // Risk adjustment
        let riskMultiplier = riskLevel.confidenceMultiplier
        
        // Base confidence calculation
        let baseConfidence = (1 - sqrt(variance)) * 0.8 + factorCountBonus
        
        // Apply modifiers
        return min(baseConfidence * weightSpread * riskMultiplier * 100, 100)
    }
    
    private func calculateWeightSpread() -> Double {
        let weights = factors.map { $0.weight }
        let maxWeight = weights.max() ?? 0
        let minWeight = weights.min() ?? 0
        
        // Penalize if weights are too similar or too different
        let spread = maxWeight - minWeight
        return 0.8 + (spread * 0.2)
    }
    
    var keyStrengths: [Factor] {
        factors.filter { $0.normalizedScore > 0.7 }
            .sorted { $0.weightedImpact > $1.weightedImpact }
    }
    
    var keyWeaknesses: [Factor] {
        factors.filter { $0.normalizedScore < 0.4 }
            .sorted { $0.weightedImpact > $1.weightedImpact }
    }
    
    var decisiveFactors: [Factor] {
        factors.filter { $0.weight > 0.7 }
            .sorted { $0.weightedImpact > $1.weightedImpact }
    }
    
    func compareWith(_ other: Option) -> ComparisonInsight {
        let strengthDiff = self.keyStrengths.count - other.keyStrengths.count
        let weaknessDiff = other.keyWeaknesses.count - self.keyWeaknesses.count
        let weightedScoreDiff = self.weightedScore - other.weightedScore
        
        return ComparisonInsight(
            advantageScore: Double(strengthDiff + weaknessDiff) * 0.2 + weightedScoreDiff,
            decisiveFactors: decisiveFactors,
            keyDifferentiators: factors.filter { factor in
                if let otherFactor = other.factors.first(where: { $0.name == factor.name }) {
                    return abs(factor.normalizedScore - otherFactor.normalizedScore) > 0.3
                }
                return false
            }
        )
    }
}

struct ComparisonInsight {
    let advantageScore: Double
    let decisiveFactors: [Factor]
    let keyDifferentiators: [Factor]
    
    var confidenceLevel: String {
        switch abs(advantageScore) {
        case 0.7...: return "High Confidence"
        case 0.4..<0.7: return "Moderate Confidence"
        default: return "Low Confidence"
        }
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

extension RiskLevel {
    var confidenceMultiplier: Double {
        switch self {
        case .veryLow: return 1.2
        case .low: return 1.1
        case .medium: return 1.0
        case .high: return 0.9
        case .veryHigh: return 0.8
        }
    }
} 
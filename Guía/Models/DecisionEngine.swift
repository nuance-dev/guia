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
    
    var confidenceScore: Double {
        // Ensure we have scores for all factors
        let scoredFactors = factors.filter { scores[$0.id] != nil }
        guard !factors.isEmpty && scoredFactors.count == factors.count else { return 0 }
        
        // Calculate weighted score
        let weightedScore = factors.reduce(0.0) { sum, factor in
            guard let score = scores[factor.id] else { return sum }
            return sum + (factor.weight * ((score + 1) / 2))
        }
        
        // Calculate normalized score (0-1)
        let totalWeight = factors.reduce(0.0) { $0 + $1.weight }
        let normalizedScore = totalWeight > 0 ? weightedScore / totalWeight : 0
        
        // Apply adjustments
        let factorCoverage = Double(scoredFactors.count) / Double(factors.count)
        let riskAdjustment = riskLevel.confidenceMultiplier
        let weightDistribution = calculateWeightDistribution()
        
        // Final confidence calculation
        return min(normalizedScore * factorCoverage * riskAdjustment * weightDistribution * 100, 100)
    }
    
    private func calculateWeightDistribution() -> Double {
        let weights = factors.map { $0.weight }
        let variance = weights.reduce(0.0) { sum, weight in
            let mean = weights.reduce(0.0, +) / Double(weights.count)
            return sum + pow(weight - mean, 2)
        } / Double(weights.count)
        
        // Return a value between 0.8 and 1.0 based on weight distribution
        return 0.8 + (0.2 * (1.0 - min(variance * 4, 1.0)))
    }
    
    var weightedScore: Double {
        let totalWeight = factors.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return 0 }
        
        return factors.reduce(0) { sum, factor in
            guard let score = scores[factor.id] else { return sum }
            return sum + ((factor.weight / totalWeight) * ((score + 1) / 2))
        }
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
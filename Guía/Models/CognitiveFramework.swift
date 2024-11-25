import Foundation

struct CognitiveFramework {
    // Core decision aspects
    struct DecisionContext {
        let timeConstraint: TimeConstraint
        let emotionalImpact: EmotionalImpact
        let reversibility: Reversibility
        let stakeholderImpact: [StakeholderImpact]
        let biasIndicators: [BiasIndicator]
    }
    
    enum TimeConstraint {
        case immediate
        case short(days: Int)
        case medium(weeks: Int)
        case long(months: Int)
        
        var pressureScore: Double {
            switch self {
            case .immediate: return 1.0
            case .short(let days): return max(0, 1 - Double(days) / 30)
            case .medium(let weeks): return max(0, 1 - Double(weeks) / 12)
            case .long(let months): return max(0, 1 - Double(months) / 12)
            }
        }
    }
    
    enum EmotionalImpact: Double {
        case minimal = 0.2
        case moderate = 0.5
        case significant = 0.8
        case critical = 1.0
    }
    
    struct Reversibility {
        let isReversible: Bool
        let cost: Double // 0-1 scale
        let timeToReverse: TimeConstraint
        
        var score: Double {
            guard isReversible else { return 1.0 }
            return (cost + timeToReverse.pressureScore) / 2
        }
    }
    
    struct StakeholderImpact {
        let stakeholder: String
        let impact: Double // -1 to 1 scale
        let influence: Double // 0 to 1 scale
        
        var weightedImpact: Double {
            return impact * influence
        }
    }
    
    struct BiasIndicator: Codable, Equatable {
        let biasType: CognitiveBias
        let confidence: Double
        let mitigationStrategy: String
    }
    
    enum CognitiveBias: String, Codable {
        case anchoring = "anchoring"
        case confirmation = "confirmation"
        case sunkCost = "sunkCost"
        case availability = "availability"
        case overconfidence = "overconfidence"
        case statusQuo = "statusQuo"
        case bandwagon = "bandwagon"
        
        var description: String {
            switch self {
            case .anchoring: return "Relying too heavily on the first piece of information"
            case .confirmation: return "Seeking information that confirms existing beliefs"
            case .sunkCost: return "Considering already invested resources too heavily"
            case .availability: return "Overweighting easily recalled information"
            case .overconfidence: return "Overestimating one's own abilities"
            case .statusQuo: return "Preferring the current state of affairs"
            case .bandwagon: return "Following the crowd without sufficient analysis"
            }
        }
    }
}
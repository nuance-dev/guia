import Foundation

class DecisionContext: ObservableObject {
    @Published var currentStep: DecisionStep = .firstOption
    @Published var firstOption: Option
    @Published var secondOption: Option
    @Published var canProceed: Bool = false
    
    init() {
        // Initialize with empty options
        self.firstOption = Option(name: "", factors: [], timeframe: .immediate, riskLevel: .medium)
        self.secondOption = Option(name: "", factors: [], timeframe: .immediate, riskLevel: .medium)
    }
    
    enum DecisionStep {
        case firstOption
        case secondOption
        case factorInput
        case factorWeighting
        case timeframeSelection
        case riskAssessment
        case scoring
        case review
    }
    
    func advanceToNextStep() {
        switch currentStep {
        case .firstOption:
            currentStep = .secondOption
        case .secondOption:
            currentStep = .factorInput
        case .factorInput:
            currentStep = .factorWeighting
        case .factorWeighting:
            currentStep = .timeframeSelection
        case .timeframeSelection:
            currentStep = .riskAssessment
        case .riskAssessment:
            currentStep = .scoring
        case .scoring:
            currentStep = .review
        case .review:
            break // Stay on review
        }
    }
    
    func handleFactorKeyboardInput(_ key: String) {
        switch key {
        case "\r": // Enter key
            advanceToNextStep()
        case "\t": // Tab key
            // Handle moving to next factor
            break
        default:
            break
        }
    }
    
    func calculateConfidence() -> Double {
        let factorWeightSum = firstOption.factors.reduce(0) { $0 + $1.weight }
        let scoreSum = firstOption.factors.reduce(0) { $0 + ($1.weight * $1.score) }
        
        // Normalize to 0-1 range
        let normalizedScore = (scoreSum / factorWeightSum + 1) / 2
        
        // Apply risk adjustment
        let riskAdjustment = calculateRiskAdjustment()
        let timeframeAdjustment = calculateTimeframeAdjustment()
        
        return normalizedScore * riskAdjustment * timeframeAdjustment
    }
    
    private func calculateRiskAdjustment() -> Double {
        switch firstOption.riskLevel {
        case .veryLow: return 1.2
        case .low: return 1.1
        case .medium: return 1.0
        case .high: return 0.9
        case .veryHigh: return 0.8
        }
    }
    
    private func calculateTimeframeAdjustment() -> Double {
        switch firstOption.timeframe {
        case .immediate: return 1.1
        case .shortTerm: return 1.05
        case .mediumTerm: return 1.0
        case .longTerm: return 0.95
        }
    }
    
    private func updateCanProceed() {
        switch currentStep {
        case .firstOption:
            canProceed = !firstOption.name.isEmpty
        case .secondOption:
            canProceed = !secondOption.name.isEmpty
        case .factorInput:
            canProceed = firstOption.factors.count > 0 && secondOption.factors.count > 0
        case .factorWeighting:
            canProceed = true // Can always proceed after weighting
        case .timeframeSelection:
            canProceed = true
        case .riskAssessment:
            canProceed = true
        case .scoring:
            canProceed = true
        case .review:
            canProceed = false // No more steps after review
        }
    }
} 
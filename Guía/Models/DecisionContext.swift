import Foundation

class DecisionContext: ObservableObject {
    @Published var mainDecision: String = ""
    @Published var options: [Option] = []
    @Published var currentStep: DecisionStep = .firstOption
    @Published var canProceed: Bool = false
    
    private let maxOptions = 3
    
    init() {
        self.options = []
    }
    
    func setMainDecision(_ decision: String) {
        mainDecision = decision
        updateCanProceed()
    }
    
    func addOption(_ name: String) {
        guard options.count < maxOptions else { return }
        let newOption = Option(
            name: name,
            factors: [],
            timeframe: .immediate,
            riskLevel: .medium
        )
        options.append(newOption)
        updateCanProceed()
    }
    
    private func updateCanProceed() {
        switch currentStep {
        case .firstOption:
            canProceed = !mainDecision.isEmpty && options.first != nil && !options.first!.name.isEmpty
        case .secondOption:
            canProceed = options.count > 1 && !options[1].name.isEmpty
        case .factorInput:
            canProceed = options.count > 1 && options.allSatisfy { !$0.factors.isEmpty }
        case .factorWeighting:
            canProceed = true
        case .timeframeSelection:
            canProceed = true
        case .riskAssessment:
            canProceed = true
        case .scoring:
            canProceed = true
        case .review:
            canProceed = false
        }
    }
    
    func canAddMoreOptions() -> Bool {
        return options.count < maxOptions
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
    guard options.count >= 2 else { return 0 }
    
    // Calculate weighted scores
    let weightedScores = options.map { option in
        option.factors.reduce(0.0) { sum, factor in
            sum + (factor.weight * factor.normalizedScore)
        }
    }
    
    // Calculate maximum possible score
    let maxPossibleScore = options.first?.factors.reduce(0.0) { sum, factor in
        sum + factor.weight
    } ?? 1.0
    
    // Normalize scores
    let normalizedScores = weightedScores.map { $0 / maxPossibleScore }
    
    // Calculate score difference between options
    let scoreDifference = abs(normalizedScores[0] - normalizedScores[1])
    
    // Base confidence on score difference and factor coverage
    let factorCoverage = min(Double(options.first?.factors.count ?? 0) / 5.0, 1.0)
    let baseConfidence = (scoreDifference * 0.7 + factorCoverage * 0.3) * 100
    
    // Apply risk and timeframe adjustments
    let riskAdjustment = calculateRiskAdjustment()
    let timeframeAdjustment = calculateTimeframeAdjustment()
    
    return min(baseConfidence * riskAdjustment * timeframeAdjustment, 100)
}
    
    private func calculateRiskAdjustment() -> Double {
        let riskLevel = options.reduce(.medium) { $1.riskLevel }
        switch riskLevel {
        case .veryLow: return 1.2
        case .low: return 1.1
        case .medium: return 1.0
        case .high: return 0.9
        case .veryHigh: return 0.8
        }
    }
    
    private func calculateTimeframeAdjustment() -> Double {
        let timeframe = options.reduce(.immediate) { $1.timeframe }
        switch timeframe {
        case .immediate: return 1.1
        case .shortTerm: return 1.05
        case .mediumTerm: return 1.0
        case .longTerm: return 0.95
        }
    }
} 
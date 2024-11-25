import SwiftUI
import Combine

@MainActor
final class DecisionFlowCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentStage: DecisionStage
    @Published private(set) var flowComplexity: FlowComplexity
    @Published private(set) var confidenceMetrics: Decision.ConfidenceMetrics
    @Published private(set) var detectedBiases: [CognitiveFramework.BiasIndicator]
    @Published private(set) var stageProgress: StageProgress
    @Published private(set) var insights: [DecisionInsight]
    @Published var showingBiasAlert: Bool = false
    
    // MARK: - Properties
    private let decision: Decision
    private let analysisEngine: AnalysisEngine
    private var cancellables = Set<AnyCancellable>()
    
    struct StageProgress {
        let completed: Bool
        let blockers: [String]
        let recommendations: [String]
        let confidenceScore: Double
    }
    
    struct DecisionInsight {
        let type: InsightType
        let message: String
        let severity: Severity
        let recommendation: String
        
        enum InsightType {
            case bias
            case dataQuality
            case stakeholder
            case sensitivity
            case tradeoff
        }
        
        enum Severity {
            case info
            case warning
            case critical
        }
    }
    
    enum FlowComplexity: Int {
        case simple
        case standard
        case advanced
        
        var requiredStages: [DecisionStage] {
            switch self {
            case .simple: return [.problem, .options, .analysis]
            case .standard: return [.problem, .options, .criteria, .weights, .analysis]
            case .advanced: return DecisionStage.allCases
            }
        }
    }
    
    // MARK: - Initialize
    init(decision: Decision, analysisEngine: AnalysisEngine = AnalysisEngine()) {
        self.decision = decision
        self.analysisEngine = analysisEngine
        self.currentStage = .problem
        self.flowComplexity = .simple
        self.confidenceMetrics = Decision.ConfidenceMetrics(
            dataQuality: 0,
            biasAwareness: 0,
            stakeholderCoverage: 0,
            criteriaCompleteness: 0
        )
        self.detectedBiases = []
        self.stageProgress = StageProgress(
            completed: false,
            blockers: [],
            recommendations: [],
            confidenceScore: 0
        )
        self.insights = []
        
        setupObservers()
        determineComplexity()
    }
    
    // MARK: - Public Methods
    func moveToNextStage() async throws {
        // Validate current stage completion
        guard canAdvance() else {
            throw DecisionError.stageIncomplete(blockers: stageProgress.blockers)
        }
        
        // Perform pre-transition analysis
        let analysisResults = try await performStageAnalysis()
        
        // Update insights and metrics
        updateInsights(with: analysisResults)
        updateConfidenceMetrics()
        
        // Check for cognitive biases
        let biases = decision.analyzeCognitiveBiases()
        if !biases.isEmpty {
            detectedBiases = biases
            showingBiasAlert = true
        }
        
        // Determine next stage based on complexity and context
        let nextStage = determineNextStage(based: analysisResults)
        
        // Transition to next stage
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentStage = nextStage
        }
        
        // Initialize new stage
        initializeStage(nextStage)
    }
    
    func canAdvance() -> Bool {
        switch currentStage {
        case .problem:
            return !decision.title.isEmpty
        case .stakeholders:
            return decision.cognitiveContext?.stakeholderImpact.count ?? 0 > 0
        case .options:
            return decision.options.count >= 2
        case .criteria:
            return !decision.criteria.isEmpty
        case .weights:
            return decision.validateWeights()
        case .analysis:
            return decision.analysisResults != nil
        case .refinement:
            return true
        case .validation:
            return confidenceMetrics.overallConfidence > 0.7
        }
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        // Add observers for decision changes
    }
    
    private func determineComplexity() {
        var complexity: FlowComplexity
        
        switch decision.criteria.count {
        case 0...2:
            complexity = .simple
        case 3...5:
            complexity = .standard
        default:
            complexity = .advanced
        }
        
        if decision.cognitiveContext?.stakeholderImpact.count ?? 0 > 2 {
            complexity = .advanced
        }
        
        self.flowComplexity = complexity
    }
    
    private func updateConfidenceMetrics() {
        // Calculate data quality
        let dataQuality = calculateDataQuality()
        
        // Calculate bias awareness
        let biasAwareness = 1.0 - (Double(detectedBiases.count) / 5.0) // Normalize to 0-1
        
        // Calculate stakeholder coverage
        let stakeholderCoverage = calculateStakeholderCoverage()
        
        // Calculate criteria completeness
        let criteriaCompleteness = calculateCriteriaCompleteness()
        
        confidenceMetrics = Decision.ConfidenceMetrics(
            dataQuality: dataQuality,
            biasAwareness: biasAwareness,
            stakeholderCoverage: stakeholderCoverage,
            criteriaCompleteness: criteriaCompleteness
        )
    }
    
    private func checkForBiases() {
        let newBiases = decision.analyzeCognitiveBiases()
        if !newBiases.isEmpty && newBiases != detectedBiases {
            detectedBiases = newBiases
            showingBiasAlert = true
        }
    }
    
    private func calculateDataQuality() -> Double {
        var quality = 1.0
        
        // Check for missing data
        let totalPossibleScores = decision.options.count * decision.criteria.count
        let actualScores = decision.options.reduce(0) { $0 + $1.scores.count }
        quality *= Double(actualScores) / Double(totalPossibleScores)
        
        // Check for weight distribution
        if let weightStdDev = calculateStandardDeviation(Array(decision.weights.values)) {
            quality *= 1.0 - (weightStdDev / 0.5) // Normalize std dev impact
        }
        
        return quality
    }
    
    private func calculateStakeholderCoverage() -> Double {
        guard let stakeholders = decision.cognitiveContext?.stakeholderImpact else {
            return 0.0
        }
        
        let totalInfluence = stakeholders.reduce(0.0) { $0 + $1.influence }
        return min(1.0, totalInfluence / 3.0) // Normalize to 0-1
    }
    
    private func calculateCriteriaCompleteness() -> Double {
        let hasFinancial = decision.criteria.contains { $0.name.lowercased().contains("cost") || $0.name.lowercased().contains("price") }
        let hasTime = decision.criteria.contains { $0.name.lowercased().contains("time") || $0.name.lowercased().contains("duration") }
        let hasQuality = decision.criteria.contains { $0.name.lowercased().contains("quality") || $0.name.lowercased().contains("performance") }
        
        var completeness = 0.0
        if hasFinancial { completeness += 0.33 }
        if hasTime { completeness += 0.33 }
        if hasQuality { completeness += 0.34 }
        
        return completeness
    }
    
    private func calculateStandardDeviation(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        
        let mean = values.reduce(0, +) / Double(values.count)
        let sumSquaredDiffs = values.reduce(0) { $0 + pow($1 - mean, 2) }
        return sqrt(sumSquaredDiffs / Double(values.count))
    }
    
    private func determineNextStage(based analysis: StageAnalysis) -> DecisionStage {
        // Smart stage progression based on analysis
        switch currentStage {
        case .problem:
            return analysis.requiresStakeholderAnalysis ? .stakeholders : .options
        case .options:
            return analysis.complexityScore > 0.7 ? .criteria : .analysis
        case .criteria:
            return analysis.hasConflictingCriteria ? .weights : .analysis
        default:
            return flowComplexity.requiredStages[
                min(
                    currentStageIndex + 1,
                    flowComplexity.requiredStages.count - 1
                )
            ]
        }
    }
    
    private func performStageAnalysis() async throws -> StageAnalysis {
        let analysis = StageAnalysis(
            requiresStakeholderAnalysis: decision.criteria.count > 3,
            complexityScore: calculateComplexityScore(),
            hasConflictingCriteria: checkForConflictingCriteria()
        )
        return analysis
    }
    
    private func updateInsights(with analysis: StageAnalysis) {
        insights = []
        
        // Add insights based on analysis
        if analysis.requiresStakeholderAnalysis {
            insights.append(DecisionInsight(
                type: .stakeholder,
                message: "Consider stakeholder impact",
                severity: .warning,
                recommendation: "Add stakeholder analysis for better decision quality"
            ))
        }
        
        if analysis.complexityScore > 0.7 {
            insights.append(DecisionInsight(
                type: .dataQuality,
                message: "High complexity detected",
                severity: .info,
                recommendation: "Break down criteria into smaller components"
            ))
        }
    }
    
    private func initializeStage(_ stage: DecisionStage) {
        stageProgress = StageProgress(
            completed: false,
            blockers: [],
            recommendations: getRecommendations(for: stage),
            confidenceScore: 0
        )
    }
    
    private var currentStageIndex: Int {
        flowComplexity.requiredStages.firstIndex(of: currentStage) ?? 0
    }
    
    private func calculateComplexityScore() -> Double {
        let criteriaCount = Double(decision.criteria.count)
        let optionsCount = Double(decision.options.count)
        let stakeholderCount = Double(decision.cognitiveContext?.stakeholderImpact.count ?? 0)
        
        return min(1.0, (criteriaCount * 0.3 + optionsCount * 0.3 + stakeholderCount * 0.4) / 10.0)
    }
    
    private func checkForConflictingCriteria() -> Bool {
        // Implement conflict detection logic
        false
    }
    
    private func getRecommendations(for stage: DecisionStage) -> [String] {
        switch stage {
        case .problem:
            return ["Define the decision problem clearly", "Consider time constraints"]
        case .stakeholders:
            return ["Identify key stakeholders", "Assess stakeholder impact"]
        case .options:
            return ["Add at least 2 options", "Consider creative alternatives"]
        case .criteria:
            return ["Define measurable criteria", "Ensure criteria are independent"]
        case .weights:
            return ["Assign weights based on importance", "Validate weight distribution"]
        case .analysis:
            return ["Review analysis results", "Check for sensitivity"]
        case .refinement:
            return ["Consider adjustments", "Review insights"]
        case .validation:
            return ["Validate final decision", "Document rationale"]
        }
    }
}

extension Decision {
    func analyzeCognitiveBiases() -> [CognitiveFramework.BiasIndicator] {
        var biases: [CognitiveFramework.BiasIndicator] = []
        
        // Check for anchoring bias
        if let firstOption = options.first,
           options.allSatisfy({ $0.scores.averageValue <= firstOption.scores.averageValue }) {
            biases.append(CognitiveFramework.BiasIndicator(
                biasType: .anchoring,
                confidence: 0.8,
                mitigationStrategy: "Consider evaluating options in random order"
            ))
        }
        
        // Add more bias checks as needed
        
        return biases
    }
    
    var cognitiveContext: CognitiveFramework.DecisionContext? {
        CognitiveFramework.DecisionContext(
            timeConstraint: .medium(weeks: 2),
            emotionalImpact: .moderate,
            reversibility: .init(
                isReversible: true,
                cost: 0.5,
                timeToReverse: .short(days: 7)
            ),
            stakeholderImpact: [],
            biasIndicators: []
        )
    }
}

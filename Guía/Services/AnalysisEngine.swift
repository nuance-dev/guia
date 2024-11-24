import Foundation

// MARK: - Analysis Method
enum AnalysisMethod: String, Codable {
    case simple // Weighted sum
    case ahp    // Analytic Hierarchy Process
    case topsis // TOPSIS method
}

// MARK: - Analysis Engine
final class AnalysisEngine {
    // MARK: - Properties
    private let ahpAnalyzer: AHPAnalyzer
    
    // MARK: - Initialize
    init() {
        self.ahpAnalyzer = AHPAnalyzer()
    }
    
    // MARK: - Public Methods
    func analyze(decision: Decision, method: AnalysisMethod) async throws -> AnalysisResults {
        switch method {
        case .simple:
            return try await performSimpleAnalysis(decision)
        case .ahp:
            return try await performAHPAnalysis(decision)
        case .topsis:
            return try await performTOPSISAnalysis(decision)
        }
    }
    
    // MARK: - Private Methods
    private func performSimpleAnalysis(_ decision: Decision) async throws -> AnalysisResults {
        let normalizedWeights = decision.normalizeWeights()
        var rankedOptions: [AnalysisResults.RankedOption] = []
        
        for option in decision.options {
            var score = 0.0
            var breakdownByCriteria: [UUID: Double] = [:]
            
            for criterion in decision.criteria {
                if let weight = normalizedWeights[criterion.id],
                   let optionScore = option.scores[criterion.id] {
                    let weightedScore = weight * optionScore
                    score += weightedScore
                    breakdownByCriteria[criterion.id] = weightedScore
                }
            }
            
            rankedOptions.append(.init(
                id: UUID(),
                optionId: option.id,
                score: score,
                rank: 0, // Will be set after sorting
                breakdownByCriteria: breakdownByCriteria
            ))
        }
        
        // Sort and assign ranks
        rankedOptions.sort { $0.score > $1.score }
        for (index, _) in rankedOptions.enumerated() {
            rankedOptions[index].rank = index + 1
        }
        
        return try await AnalysisResults(
            rankedOptions: rankedOptions,
            confidenceScore: calculateConfidenceScore(rankedOptions),
            sensitivityData: calculateSensitivityData(decision, rankedOptions),
            method: .simple,
            criteria: decision.criteria
        )
    }
    
    private func performAHPAnalysis(_ decision: Decision) async throws -> AnalysisResults {
        // Create pairwise comparison matrix from weights
        let pairwiseMatrix = createPairwiseMatrix(from: decision)
        
        // Create options matrix for each criterion
        let optionsMatrix = createOptionsMatrix(from: decision)
        
        // Use AHPAnalyzer to perform the analysis
        let ahpResults = try ahpAnalyzer.analyze(
            criteria: decision.criteria,
            pairwiseMatrix: pairwiseMatrix,
            optionsMatrix: optionsMatrix
        )
        
        // Convert AHP results to AnalysisResults format
        var rankedOptions: [AnalysisResults.RankedOption] = []
        
        for (index, option) in decision.options.enumerated() {
            var breakdownByCriteria: [UUID: Double] = [:]
            
            // Calculate breakdown by criteria
            for (criterionIndex, criterion) in decision.criteria.enumerated() {
                breakdownByCriteria[criterion.id] = ahpResults.optionScores[criterionIndex][index]
            }
            
            rankedOptions.append(.init(
                id: UUID(),
                optionId: option.id,
                score: ahpResults.finalScores[index],
                rank: 0, // Will be set after sorting
                breakdownByCriteria: breakdownByCriteria
            ))
        }
        
        // Sort and assign ranks
        rankedOptions.sort { $0.score > $1.score }
        for (index, _) in rankedOptions.enumerated() {
            rankedOptions[index].rank = index + 1
        }
        
        return try await AnalysisResults(
            rankedOptions: rankedOptions,
            confidenceScore: 1.0 - ahpResults.consistencyRatio,
            sensitivityData: calculateSensitivityData(decision, rankedOptions),
            method: .ahp
        )
    }
    
    private func createPairwiseMatrix(from decision: Decision) -> [[Double]] {
        let n = decision.criteria.count
        var matrix = Array(repeating: Array(repeating: 1.0, count: n), count: n)
        
        for i in 0..<n {
            for j in 0..<n {
                if i != j {
                    let wi = decision.weights[decision.criteria[i].id] ?? 1.0
                    let wj = decision.weights[decision.criteria[j].id] ?? 1.0
                    matrix[i][j] = wi / wj
                }
            }
        }
        
        return matrix
    }
    
    private func createOptionsMatrix(from decision: Decision) -> [[[Double]]] {
        decision.criteria.map { criterion in
            let n = decision.options.count
            var matrix = Array(repeating: Array(repeating: 1.0, count: n), count: n)
            
            for i in 0..<n {
                for j in 0..<n {
                    if i != j {
                        let si = decision.options[i].scores[criterion.id] ?? 1.0
                        let sj = decision.options[j].scores[criterion.id] ?? 1.0
                        matrix[i][j] = si / sj
                    }
                }
            }
            
            return matrix
        }
    }
    
    private func performTOPSISAnalysis(_ decision: Decision) async throws -> AnalysisResults {
        let normalizedWeights = decision.normalizeWeights()
        let n = decision.options.count
        let m = decision.criteria.count
        
        // Step 1: Construct normalized decision matrix
        var normalizedMatrix: [[Double]] = Array(repeating: Array(repeating: 0.0, count: m), count: n)
        
        for (i, option) in decision.options.enumerated() {
            for (j, criterion) in decision.criteria.enumerated() {
                if let score = option.scores[criterion.id] {
                    let sumOfSquares = decision.options.compactMap { $0.scores[criterion.id] }
                        .map { $0 * $0 }
                        .reduce(0.0, +)
                    normalizedMatrix[i][j] = score / sqrt(sumOfSquares)
                }
            }
        }
        
        // Step 2: Calculate weighted normalized decision matrix
        var weightedMatrix = normalizedMatrix
        for j in 0..<m {
            let criterion = decision.criteria[j]
            if let weight = normalizedWeights[criterion.id] {
                for i in 0..<n {
                    weightedMatrix[i][j] *= weight
                }
            }
        }
        
        // Step 3: Determine ideal and negative-ideal solutions
        var idealSolution = Array(repeating: -Double.infinity, count: m)
        var negativeIdealSolution = Array(repeating: Double.infinity, count: m)
        
        for j in 0..<m {
            for i in 0..<n {
                idealSolution[j] = max(idealSolution[j], weightedMatrix[i][j])
                negativeIdealSolution[j] = min(negativeIdealSolution[j], weightedMatrix[i][j])
            }
        }
        
        // Step 4: Calculate separation measures and relative closeness
        var rankedOptions: [AnalysisResults.RankedOption] = []
        
        for (i, option) in decision.options.enumerated() {
            var separationIdeal = 0.0
            var separationNegative = 0.0
            var breakdownByCriteria: [UUID: Double] = [:]
            
            for (j, criterion) in decision.criteria.enumerated() {
                let value = weightedMatrix[i][j]
                separationIdeal += pow(value - idealSolution[j], 2)
                separationNegative += pow(value - negativeIdealSolution[j], 2)
                breakdownByCriteria[criterion.id] = value
            }
            
            separationIdeal = sqrt(separationIdeal)
            separationNegative = sqrt(separationNegative)
            
            let relativeCloseness = separationNegative / (separationIdeal + separationNegative)
            
            rankedOptions.append(.init(
                id: UUID(),
                optionId: option.id,
                score: relativeCloseness,
                rank: 0,
                breakdownByCriteria: breakdownByCriteria
            ))
        }
        
        // Sort and assign ranks
        rankedOptions.sort { $0.score > $1.score }
        for (index, _) in rankedOptions.enumerated() {
            rankedOptions[index].rank = index + 1
        }
        
        return try await AnalysisResults(
            rankedOptions: rankedOptions,
            confidenceScore: calculateConfidenceScore(rankedOptions),
            sensitivityData: calculateSensitivityData(decision, rankedOptions),
            method: .topsis
        )
    }
    
    private func calculateConfidenceScore(_ rankedOptions: [AnalysisResults.RankedOption]) -> Double {
        guard rankedOptions.count > 1 else { return 1.0 }
        
        let maxScore = rankedOptions[0].score
        let minScore = rankedOptions.last?.score ?? 0.0
        let range = maxScore - minScore
        
        // Calculate average difference between consecutive scores
        var avgDiff = 0.0
        for i in 0..<rankedOptions.count-1 {
            avgDiff += abs(rankedOptions[i].score - rankedOptions[i+1].score)
        }
        avgDiff /= Double(rankedOptions.count - 1)
        
        // Normalize to [0,1] range
        return min(1.0, avgDiff / (range / Double(rankedOptions.count)))
    }
    
    private func calculateSensitivityData(_ decision: Decision, _ rankedOptions: [AnalysisResults.RankedOption]) async throws -> SensitivityData {
        var weightSensitivity: [UUID: Double] = [:]
        let scoreSensitivity: [UUID: Double] = [:]
        var criticalCriteria: [UUID] = []
        var switchingPoints: [SensitivityData.SwitchingPoint] = []
        
        // Calculate weight sensitivity for each criterion
        for criterion in decision.criteria {
            let baseRanking = rankedOptions.map { $0.optionId }
            var sensitivityScore = 0.0
            
            // Test weight perturbations
            for delta in [-0.1, -0.05, 0.05, 0.1] {
                var modifiedWeights = decision.weights
                let originalWeight = modifiedWeights[criterion.id] ?? 0.0
                modifiedWeights[criterion.id] = max(0, min(1, originalWeight * (1 + delta)))
                
                do {
                    let modifiedResults = try await performTemporaryAnalysis(
                        decision: decision,
                        modifiedWeights: modifiedWeights
                    )
                    let modifiedRanking = modifiedResults.rankedOptions.map { $0.optionId }
                    
                    if baseRanking != modifiedRanking {
                        sensitivityScore += abs(delta)
                        
                        if let switchPoint = try await findSwitchingPoint(
                            criterion: criterion,
                            originalWeight: originalWeight,
                            baseRanking: baseRanking,
                            modifiedRanking: modifiedRanking
                        ) {
                            switchingPoints.append(switchPoint)
                        }
                    }
                } catch {
                    continue // Skip failed analysis attempts
                }
            }
            
            weightSensitivity[criterion.id] = sensitivityScore
            
            if sensitivityScore > 0.15 {
                criticalCriteria.append(criterion.id)
            }
        }
        
        let avgSensitivity = weightSensitivity.values.reduce(0.0, +) / Double(weightSensitivity.count)
        let stabilityIndex = 1.0 - min(1.0, avgSensitivity)
        
        return SensitivityData(
            weightSensitivity: weightSensitivity,
            scoreSensitivity: scoreSensitivity,
            stabilityIndex: stabilityIndex,
            criticalCriteria: criticalCriteria,
            switchingPoints: switchingPoints
        )
    }
    
    private func findSwitchingPoint(
        criterion: Criterion,
        originalWeight: Double,
        baseRanking: [UUID],
        modifiedRanking: [UUID]
    ) async throws -> SensitivityData.SwitchingPoint? {
        for (i, optionId) in baseRanking.enumerated() {
            if let newPosition = modifiedRanking.firstIndex(of: optionId),
               newPosition != i {
                return SensitivityData.SwitchingPoint(
                    criterionId: criterion.id,
                    currentWeight: originalWeight,
                    switchingWeight: originalWeight * 1.1,
                    affectedOptions: (optionId, modifiedRanking[i])
                )
            }
        }
        return nil
    }
    
    private func performTemporaryAnalysis(
        decision: Decision,
        modifiedWeights: [UUID: Double]
    ) async throws -> AnalysisResults {
        var modifiedDecision = decision
        modifiedDecision.weights = modifiedWeights
        return try await analyze(decision: modifiedDecision, method: .simple)
    }
}

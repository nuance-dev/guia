import Foundation
import Accelerate

final class AHPAnalyzer {
    // MARK: - Properties
    private let consistencyThreshold = 0.1
    private let randomConsistencyIndex: [Double] = [0, 0, 0.58, 0.9, 1.12, 1.24, 1.32, 1.41, 1.45, 1.49]
    private var criteriaWeights: [Double] = []
    private var optionScores: [[Double]] = []
    
    // MARK: - Public Methods
    func analyze(criteria: [Criterion], 
                pairwiseMatrix: [[Double]], 
                optionsMatrix: [[[Double]]]) throws -> AHPResults {
        // Validate input matrices
        try validateMatrices(criteriaCount: criteria.count, 
                           pairwiseMatrix: pairwiseMatrix, 
                           optionsMatrix: optionsMatrix)
        
        // Calculate criteria weights
        let (weights, consistencyRatio) = try calculatePriorities(pairwiseMatrix)
        self.criteriaWeights = weights  // Store weights
        
        guard consistencyRatio <= consistencyThreshold else {
            throw AHPError.inconsistentJudgments(ratio: consistencyRatio)
        }
        
        // Calculate option scores for each criterion
        let scores = try optionsMatrix.map { matrix in
            try calculatePriorities(matrix).priorities
        }
        self.optionScores = scores  // Store scores
        
        // Calculate final scores using matrix multiplication
        let finalScores = calculateFinalScores(
            criteriaWeights: weights,
            optionScores: scores
        )
        
        return AHPResults(
            criteriaWeights: weights,
            optionScores: scores,
            finalScores: finalScores,
            consistencyRatio: consistencyRatio
        )
    }
    
    func calculateRankings(withModifiedWeights weights: [Double]? = nil) throws -> [Double] {
        guard !criteriaWeights.isEmpty && !optionScores.isEmpty else {
            throw AHPError.insufficientData
        }
        
        // If no modified weights provided, use current weights
        let weightsToUse = weights ?? criteriaWeights
        
        // Calculate final scores using the weights
        return calculateFinalScores(
            criteriaWeights: weightsToUse,
            optionScores: optionScores
        )
    }
    
    // MARK: - Private Methods
    private func calculatePriorities(_ matrix: [[Double]]) throws -> (priorities: [Double], consistencyRatio: Double) {
        let n = matrix.count
        let workMatrix = matrix
        
        // Use Accelerate framework for efficient matrix operations
        // Convert to row-major format for BLAS
        var eigenVector = [Double](repeating: 1.0 / Double(n), count: n)
        var prevEigenVector = eigenVector
        
        // Power iteration method for principal eigenvector
        for _ in 0..<100 { // Max iterations
            // Matrix-vector multiplication using BLAS
            var result = [Double](repeating: 0.0, count: n)
            vDSP_mmulD(workMatrix.flatMap { $0 }, 1,
                      eigenVector, 1,
                      &result, 1,
                      UInt(n), 1, UInt(n))
            
            // Normalize
            var sum = 0.0
            vDSP_sveD(result, 1, &sum, UInt(n))
            vDSP_vsdivD(result, 1, &sum, &eigenVector, 1, UInt(n))
            
            // Check convergence
            let diff = zip(eigenVector, prevEigenVector)
                .map { abs($0 - $1) }
                .max() ?? 0
            
            if diff < 1e-10 {
                break
            }
            
            prevEigenVector = eigenVector
        }
        
        // Calculate consistency ratio
        let consistencyRatio = try calculateConsistencyRatio(
            matrix: matrix,
            eigenVector: eigenVector
        )
        
        return (eigenVector, consistencyRatio)
    }
    
    private func calculateConsistencyRatio(matrix: [[Double]], eigenVector: [Double]) throws -> Double {
        let n = matrix.count
        
        // Calculate λmax (principal eigenvalue)
        var lambdaMax = 0.0
        for i in 0..<n {
            var sum = 0.0
            for j in 0..<n {
                sum += matrix[i][j] * eigenVector[j]
            }
            lambdaMax += sum / eigenVector[i]
        }
        lambdaMax /= Double(n)
        
        // Calculate Consistency Index (CI)
        let ci = (lambdaMax - Double(n)) / Double(n - 1)
        
        // Get Random Consistency Index (RI)
        guard n > 1, n <= randomConsistencyIndex.count else {
            throw AHPError.invalidMatrixSize
        }
        let ri = randomConsistencyIndex[n - 1]
        
        return ci / ri
    }
    
    private func validateMatrices(criteriaCount: Int, 
                                 pairwiseMatrix: [[Double]], 
                                 optionsMatrix: [[[Double]]]) throws {
        // Validate pairwise matrix dimensions
        guard pairwiseMatrix.count == criteriaCount,
              pairwiseMatrix.allSatisfy({ $0.count == criteriaCount }) else {
            throw AHPError.invalidMatrixSize
        }
        
        // Validate options matrix dimensions
        guard optionsMatrix.count == criteriaCount,
              optionsMatrix.allSatisfy({ matrix in
                  let optionCount = matrix.count
                  return matrix.allSatisfy { $0.count == optionCount }
              }) else {
            throw AHPError.invalidMatrixSize
        }
    }
    
    private func calculateFinalScores(criteriaWeights: [Double], 
                                    optionScores: [[Double]]) -> [Double] {
        let optionCount = optionScores[0].count
        var finalScores = [Double](repeating: 0.0, count: optionCount)
        
        // Matrix multiplication: optionScores * criteriaWeights
        for i in 0..<optionCount {
            for j in 0..<criteriaWeights.count {
                finalScores[i] += optionScores[j][i] * criteriaWeights[j]
            }
        }
        
        return finalScores
    }
}

// MARK: - AHP Results
struct AHPResults {
    let criteriaWeights: [Double]
    let optionScores: [[Double]]
    let finalScores: [Double]
    let consistencyRatio: Double
}

// MARK: - AHP Error
enum AHPError: LocalizedError {
    case invalidMatrixSize
    case inconsistentJudgments(ratio: Double)
    case singularMatrix
    case insufficientData
    
    var errorDescription: String? {
        switch self {
        case .invalidMatrixSize:
            return "Invalid matrix size for AHP analysis"
        case .inconsistentJudgments(let ratio):
            return "Inconsistent judgments detected (CR = \(ratio))"
        case .singularMatrix:
            return "Singular matrix detected, cannot perform analysis"
        case .insufficientData:
            return "Insufficient data to perform AHP analysis"
        }
    }
}
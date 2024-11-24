import Foundation
import Accelerate

final class AHPAnalyzer {
    // MARK: - Properties
    private let consistencyThreshold = 0.1
    private let randomConsistencyIndex: [Double] = [0, 0, 0.58, 0.9, 1.12, 1.24, 1.32, 1.41, 1.45, 1.49]
    
    // MARK: - Public Methods
    func analyze(criteria: [Criterion], 
                pairwiseMatrix: [[Double]], 
                optionsMatrix: [[[Double]]]) throws -> AHPResults {
        // Validate input matrices
        try validateMatrices(criteriaCount: criteria.count, 
                           pairwiseMatrix: pairwiseMatrix, 
                           optionsMatrix: optionsMatrix)
        
        // Calculate criteria weights
        let (criteriaWeights, consistencyRatio) = try calculatePriorities(pairwiseMatrix)
        
        guard consistencyRatio <= consistencyThreshold else {
            throw AHPError.inconsistentJudgments(ratio: consistencyRatio)
        }
        
        // Calculate option scores for each criterion
        let optionScores = try optionsMatrix.map { matrix in
            try calculatePriorities(matrix).priorities
        }
        
        // Calculate final scores using matrix multiplication
        let finalScores = calculateFinalScores(
            criteriaWeights: criteriaWeights,
            optionScores: optionScores
        )
        
        return AHPResults(
            criteriaWeights: criteriaWeights,
            optionScores: optionScores,
            finalScores: finalScores,
            consistencyRatio: consistencyRatio
        )
    }
    
    // MARK: - Private Methods
    private func calculatePriorities(_ matrix: [[Double]]) throws -> (priorities: [Double], consistencyRatio: Double) {
        let n = matrix.count
        var workMatrix = matrix
        
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
    
    var errorDescription: String? {
        switch self {
        case .invalidMatrixSize:
            return "Invalid matrix size for AHP analysis"
        case .inconsistentJudgments(let ratio):
            return "Inconsistent judgments detected (CR = \(ratio))"
        case .singularMatrix:
            return "Singular matrix detected, cannot perform analysis"
        }
    }
}
import Foundation

enum AnalysisError: LocalizedError {
    case invalidMatrixDimensions
    case insufficientData
    case calculationError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidMatrixDimensions:
            return "Invalid matrix dimensions for analysis"
        case .insufficientData:
            return "Insufficient data to perform analysis"
        case .calculationError(let message):
            return "Calculation error: \(message)"
        }
    }
}

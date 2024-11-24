import SwiftUI
import Combine

@MainActor
final class DecisionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var decision: Decision
    @Published private(set) var analysisState: AnalysisState = .idle
    @Published var selectedMethod: AnalysisMethod = .simple
    
    // MARK: - Dependencies
    private let analysisEngine: AnalysisEngine
    private let storageService: StorageService
    
    // MARK: - Public Methods
    func addOption(_ option: Option) async throws
    func updateOption(_ option: Option) async throws
    func deleteOption(_ option: Option) async throws
    
    func addCriterion(_ criterion: Criterion) async throws
    func updateCriterion(_ criterion: Criterion) async throws
    func deleteCriterion(_ criterion: Criterion) async throws
    
    func updateWeight(for criterion: Criterion, to value: Double) async throws
    
    func performAnalysis() async throws {
        analysisState = .analyzing
        
        do {
            let results = try await analysisEngine.analyze(
                decision: decision,
                method: selectedMethod
            )
            decision.analysisResults = results
            analysisState = .completed(results)
        } catch {
            analysisState = .error(error)
        }
    }
    
    // MARK: - Analysis State
    enum AnalysisState {
        case idle
        case analyzing
        case completed(AnalysisResults)
        case error(Error)
    }
}
import CoreData
import Foundation

@objc(DecisionEntity)
public class DecisionEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var desc: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
    @NSManaged public var status: String
    @NSManaged public var optionsData: Data?
    @NSManaged public var criteriaData: Data?
    @NSManaged public var weightsData: Data?
    @NSManaged public var analysisResultsData: Data?
    @NSManaged public var pairwiseComparisonsData: Data?
    
    public func configure(with decision: Decision) throws {
        self.id = decision.id
        self.title = decision.title
        self.desc = decision.description
        self.createdAt = decision.created
        self.modifiedAt = decision.modified
        self.status = decision.state.rawValue
        
        let encoder = JSONEncoder()
        do {
            self.optionsData = try encoder.encode(decision.options)
            self.criteriaData = try encoder.encode(decision.criteria)
            self.weightsData = try encoder.encode(decision.weights)
            if let results = decision.analysisResults {
                self.analysisResultsData = try encoder.encode(results)
            }
            if let comparisons = decision.pairwiseComparisons {
                self.pairwiseComparisonsData = try encoder.encode(comparisons)
            }
        } catch {
            throw error
        }
    }
    
    public func toDomain() throws -> Decision {
        let decoder = JSONDecoder()
        
        guard let optionsData = self.optionsData,
              let criteriaData = self.criteriaData,
              let weightsData = self.weightsData else {
            throw NSError(domain: "DecisionEntity", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing required data"])
        }
        
        let options = try decoder.decode([OptionModel].self, from: optionsData)
        let criteria = try decoder.decode([BasicCriterion].self, from: criteriaData)
        let weights = try decoder.decode([UUID: Double].self, from: weightsData)
        
        let analysisResults = try analysisResultsData.flatMap { data in
            try decoder.decode(AnalysisResults.self, from: data)
        }
        
        let pairwiseComparisons = try pairwiseComparisonsData.flatMap { data in
            try decoder.decode([[Double]].self, from: data)
        }
        
        let context = Decision.DecisionContext(
            timeframe: .immediate,
            impact: .medium,
            reversibility: true
        )
        
        return Decision(
            id: id,
            title: title,
            description: desc,
            context: context,
            options: options,
            criteria: criteria,
            weights: weights,
            evaluation: Decision.Evaluation(criteria: [], scores: [:]),
            insights: [],
            pairwiseComparisons: pairwiseComparisons,
            analysisResults: analysisResults,
            state: DecisionState(rawValue: status) ?? .empty,
            created: createdAt,
            modified: modifiedAt
        )
    }
}

extension Dictionary where Value == Double {
    var averageValue: Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
} 

import CoreData

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
    
    func configure(with decision: Decision) {
        self.id = decision.id
        self.title = decision.title
        self.desc = decision.description
        self.createdAt = decision.created
        self.modifiedAt = decision.modified
        self.status = decision.state.rawValue
        
        // Encode collections to Data
        let encoder = JSONEncoder()
        self.optionsData = try? encoder.encode(decision.options)
        self.criteriaData = try? encoder.encode(decision.criteria)
        self.weightsData = try? encoder.encode(decision.weights)
        self.analysisResultsData = try? encoder.encode(decision.analysisResults)
        self.pairwiseComparisonsData = try? encoder.encode(decision.pairwiseComparisons)
    }
    
    func toDomain() -> Decision {
        let decoder = JSONDecoder()
        
        let options = (try? decoder.decode([Option].self, from: optionsData ?? Data())) ?? []
        let criteria = (try? decoder.decode([Criterion].self, from: criteriaData ?? Data())) ?? []
        let weights = (try? decoder.decode([UUID: Double].self, from: weightsData ?? Data())) ?? [:]
        let results = try? decoder.decode(AnalysisResults.self, from: analysisResultsData ?? Data())
        let pairwiseComparisons = try? decoder.decode([[Double]].self, from: pairwiseComparisonsData ?? Data())
        
        return Decision(
            id: id,
            title: title,
            description: desc,
            options: options,
            criteria: criteria,
            weights: weights,
            pairwiseComparisons: pairwiseComparisons,
            created: createdAt,
            modified: modifiedAt,
            analysisResults: results
        )
    }
} 
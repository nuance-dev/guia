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
        
        // Create a dictionary representing the Decision structure
        var decisionDict: [String: Any] = [
            "id": id,
            "title": title,
            "description": desc as Any,
            "context": [
                "timeframe": "immediate",
                "impact": "medium",
                "reversibility": true
            ]
        ]
        
        // Safely decode collections
        if let optionsData = optionsData,
           let options = try? decoder.decode([Option].self, from: optionsData) {
            decisionDict["options"] = options
        } else {
            decisionDict["options"] = []
        }
        
        if let criteriaData = criteriaData,
           let criteria = try? decoder.decode([Criterion].self, from: criteriaData) {
            decisionDict["criteria"] = criteria
        } else {
            decisionDict["criteria"] = []
        }
        
        if let weightsData = weightsData,
           let weights = try? decoder.decode([UUID: Double].self, from: weightsData) {
            decisionDict["weights"] = weights
        } else {
            decisionDict["weights"] = [:]
        }
        
        decisionDict["evaluation"] = [
            "criteria": [],
            "scores": [:]
        ]
        
        decisionDict["insights"] = []
        
        if let pairwiseData = pairwiseComparisonsData {
            decisionDict["pairwiseComparisons"] = try? decoder.decode([[Double]].self, from: pairwiseData)
        }
        
        if let analysisData = analysisResultsData {
            decisionDict["analysisResults"] = try? decoder.decode(AnalysisResults.self, from: analysisData)
        }
        
        decisionDict["state"] = status
        decisionDict["created"] = createdAt
        decisionDict["modified"] = modifiedAt
        
        // Convert dictionary to JSON Data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: decisionDict) else {
            fatalError("Failed to create Decision JSON")
        }
        
        // Decode JSON Data into Decision object
        do {
            return try decoder.decode(Decision.self, from: jsonData)
        } catch {
            print("Error decoding Decision: \(error)")
            fatalError("Failed to decode Decision")
        }
    }
}

extension Dictionary where Value == Double {
    var averageValue: Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
} 

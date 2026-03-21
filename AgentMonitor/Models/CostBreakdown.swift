import Foundation

struct CostBreakdown: Codable, Sendable {
    let timeline: [CostTimelineEntry]
    let byProject: [CostEntry]
    let byModel: [CostEntry]
}

struct CostTimelineEntry: Codable, Identifiable, Sendable {
    var id: String { date }
    let date: String
    let costUsd: Double
}

struct CostEntry: Codable, Identifiable, Sendable {
    var id: String { key }
    let key: String
    let costUsd: Double

    var formattedCost: String {
        Formatters.cost(costUsd)
    }

    // Server sends different key names depending on the breakdown type.
    // We normalize to a single `key` field.
    enum CodingKeys: String, CodingKey {
        case project, model, costUsd
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        costUsd = try container.decode(Double.self, forKey: .costUsd)
        if let project = try container.decodeIfPresent(String.self, forKey: .project) {
            key = project
        } else if let model = try container.decodeIfPresent(String.self, forKey: .model) {
            key = model
        } else {
            key = "Unknown"
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(costUsd, forKey: .costUsd)
        try container.encode(key, forKey: .project)
    }

    init(key: String, costUsd: Double) {
        self.key = key
        self.costUsd = costUsd
    }
}

import Foundation

/// Defines all server API endpoints the app consumes.
enum APIEndpoint {
    // V1 — Real-time monitoring
    case health
    case stats
    case costStats
    case toolStats
    case usageMonitor
    case events(filters: EventFilters)
    case sessions(filters: SessionFilters)
    case sessionDetail(id: String)
    case sessionTranscript(id: String)
    case filterOptions
    case stream(agentType: String?, eventType: String?)

    // V2 — Session browser
    case v2Sessions(filters: V2SessionFilters)
    case v2SessionDetail(id: String)
    case v2SessionMessages(id: String, offset: Int, limit: Int)
    case v2SessionChildren(id: String)
    case v2Search(query: String, project: String?, agent: String?, limit: Int?)
    case v2AnalyticsSummary
    case v2AnalyticsActivity(days: Int?)
    case v2AnalyticsProjects
    case v2AnalyticsTools
    case v2Projects
    case v2Agents

    var path: String {
        switch self {
        case .health: return "/api/health"
        case .stats: return "/api/stats"
        case .costStats: return "/api/stats/cost"
        case .toolStats: return "/api/stats/tools"
        case .usageMonitor: return "/api/stats/usage-monitor"
        case .events: return "/api/events"
        case .sessions: return "/api/sessions"
        case .sessionDetail(let id): return "/api/sessions/\(id)"
        case .sessionTranscript(let id): return "/api/sessions/\(id)/transcript"
        case .filterOptions: return "/api/filter-options"
        case .stream: return "/api/stream"
        case .v2Sessions: return "/api/v2/sessions"
        case .v2SessionDetail(let id): return "/api/v2/sessions/\(id)"
        case .v2SessionMessages(let id, _, _): return "/api/v2/sessions/\(id)/messages"
        case .v2SessionChildren(let id): return "/api/v2/sessions/\(id)/children"
        case .v2Search: return "/api/v2/search"
        case .v2AnalyticsSummary: return "/api/v2/analytics/summary"
        case .v2AnalyticsActivity: return "/api/v2/analytics/activity"
        case .v2AnalyticsProjects: return "/api/v2/analytics/projects"
        case .v2AnalyticsTools: return "/api/v2/analytics/tools"
        case .v2Projects: return "/api/v2/projects"
        case .v2Agents: return "/api/v2/agents"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .events(let f):
            return f.queryItems
        case .sessions(let f):
            return f.queryItems
        case .v2Sessions(let f):
            return f.queryItems
        case .v2SessionMessages(_, let offset, let limit):
            return [
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(limit)"),
            ]
        case .v2Search(let q, let project, let agent, let limit):
            var items = [URLQueryItem(name: "q", value: q)]
            if let p = project { items.append(URLQueryItem(name: "project", value: p)) }
            if let a = agent { items.append(URLQueryItem(name: "agent", value: a)) }
            if let l = limit { items.append(URLQueryItem(name: "limit", value: "\(l)")) }
            return items
        case .v2AnalyticsActivity(let days):
            guard let d = days else { return [] }
            return [URLQueryItem(name: "days", value: "\(d)")]
        case .stream(let agentType, let eventType):
            var items: [URLQueryItem] = []
            if let a = agentType { items.append(URLQueryItem(name: "agent_type", value: a)) }
            if let e = eventType { items.append(URLQueryItem(name: "event_type", value: e)) }
            return items
        default:
            return []
        }
    }
}

// MARK: - Filter Types

struct EventFilters {
    var agentType: String?
    var eventType: String?
    var toolName: String?
    var sessionId: String?
    var branch: String?
    var model: String?
    var source: String?
    var since: String?
    var until: String?
    var limit: Int?

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let v = agentType { items.append(URLQueryItem(name: "agent_type", value: v)) }
        if let v = eventType { items.append(URLQueryItem(name: "event_type", value: v)) }
        if let v = toolName { items.append(URLQueryItem(name: "tool_name", value: v)) }
        if let v = sessionId { items.append(URLQueryItem(name: "session_id", value: v)) }
        if let v = branch { items.append(URLQueryItem(name: "branch", value: v)) }
        if let v = model { items.append(URLQueryItem(name: "model", value: v)) }
        if let v = source { items.append(URLQueryItem(name: "source", value: v)) }
        if let v = since { items.append(URLQueryItem(name: "since", value: v)) }
        if let v = until { items.append(URLQueryItem(name: "until", value: v)) }
        if let v = limit { items.append(URLQueryItem(name: "limit", value: "\(v)")) }
        return items
    }
}

struct SessionFilters {
    var status: String?
    var excludeStatus: String?
    var agentType: String?
    var since: String?
    var limit: Int?

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let v = status { items.append(URLQueryItem(name: "status", value: v)) }
        if let v = excludeStatus { items.append(URLQueryItem(name: "exclude_status", value: v)) }
        if let v = agentType { items.append(URLQueryItem(name: "agent_type", value: v)) }
        if let v = since { items.append(URLQueryItem(name: "since", value: v)) }
        if let v = limit { items.append(URLQueryItem(name: "limit", value: "\(v)")) }
        return items
    }
}

struct V2SessionFilters {
    var project: String?
    var agent: String?
    var dateFrom: String?
    var dateTo: String?
    var minMessages: Int?
    var maxMessages: Int?
    var cursor: String?
    var limit: Int?

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let v = project { items.append(URLQueryItem(name: "project", value: v)) }
        if let v = agent { items.append(URLQueryItem(name: "agent", value: v)) }
        if let v = dateFrom { items.append(URLQueryItem(name: "date_from", value: v)) }
        if let v = dateTo { items.append(URLQueryItem(name: "date_to", value: v)) }
        if let v = minMessages { items.append(URLQueryItem(name: "min_messages", value: "\(v)")) }
        if let v = maxMessages { items.append(URLQueryItem(name: "max_messages", value: "\(v)")) }
        if let v = cursor { items.append(URLQueryItem(name: "cursor", value: v)) }
        if let v = limit { items.append(URLQueryItem(name: "limit", value: "\(v)")) }
        return items
    }
}

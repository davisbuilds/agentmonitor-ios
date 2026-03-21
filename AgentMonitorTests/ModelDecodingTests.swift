import Testing
import Foundation
@testable import AgentMonitorCore

@Suite("Model Decoding Tests")
struct ModelDecodingTests {
    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    @Test("AgentEvent decodes from server JSON")
    func agentEventDecodes() throws {
        let json = loadFixture("event_response")
        let event = try decoder.decode(AgentEvent.self, from: json)

        #expect(event.id == 42)
        #expect(event.eventId == "evt-abc123")
        #expect(event.sessionId == "sess-001")
        #expect(event.agentType == "claude_code")
        #expect(event.eventType == .toolUse)
        #expect(event.toolName == "Read")
        #expect(event.status == .success)
        #expect(event.tokensIn == 1200)
        #expect(event.tokensOut == 340)
        #expect(event.cacheReadTokens == 500)
        #expect(event.cacheWriteTokens == nil)
        #expect(event.branch == "main")
        #expect(event.project == "agentmonitor")
        #expect(event.durationMs == 45)
        #expect(event.model == "claude-sonnet-4-5-20250514")
        #expect(event.costUsd == 0.0023)
        #expect(event.source == .hook)
        #expect(event.totalTokens == 1540)
    }

    @Test("Stats decodes from server JSON")
    func statsDecodes() throws {
        let json = loadFixture("stats_response")
        let stats = try decoder.decode(Stats.self, from: json)

        #expect(stats.totalEvents == 1523)
        #expect(stats.activeSessions == 2)
        #expect(stats.activeAgents == 2)
        #expect(stats.totalCostUsd == 4.52)
        #expect(stats.toolBreakdown["Read"] == 245)
        #expect(stats.agentBreakdown["claude_code"] == 1200)
        #expect(stats.branches.contains("main"))
        #expect(stats.totalTokens == 584200 + 123400)
    }

    @Test("EventType handles unknown values gracefully")
    func unknownEventType() throws {
        let json = """
        {
            "id": 1,
            "session_id": "s1",
            "agent_type": "test",
            "event_type": "future_event_type",
            "created_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!

        let event = try decoder.decode(AgentEvent.self, from: json)
        #expect(event.eventType == .unknown("future_event_type"))
        #expect(event.eventType.rawValue == "future_event_type")
    }

    @Test("SessionStatus handles unknown values")
    func unknownSessionStatus() throws {
        let json = """
        {
            "id": "s1",
            "agent_id": "a1",
            "agent_type": "test",
            "status": "paused",
            "started_at": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!

        let session = try decoder.decode(Session.self, from: json)
        #expect(session.status == .unknown("paused"))
    }

    @Test("AgentEvent computed properties")
    func eventComputedProperties() throws {
        let json = loadFixture("event_response")
        let event = try decoder.decode(AgentEvent.self, from: json)

        #expect(event.totalTokens == 1540)
        #expect(event.formattedCost == "<$0.01") // 0.0023 < 0.01
    }

    @Test("Stats.empty has zero values")
    func statsEmpty() {
        let stats = Stats.empty
        #expect(stats.totalEvents == 0)
        #expect(stats.totalCostUsd == 0)
        #expect(stats.formattedCost == "$0.00")
    }

    // MARK: - Helpers

    private func loadFixture(_ name: String) -> Data {
        // In SPM test targets, resources are in Bundle.module
        let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")!
        return try! Data(contentsOf: url)
    }
}

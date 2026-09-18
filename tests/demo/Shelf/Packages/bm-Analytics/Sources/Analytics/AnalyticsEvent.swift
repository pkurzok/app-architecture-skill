import Foundation

/// One tracked event. A value, so it can be compared in a test without a live backend.
public struct AnalyticsEvent: Equatable, Sendable {
    public let name: String
    public let parameters: [String: String]

    public init(name: String, parameters: [String: String] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

/// Where tracked events go. Implemented once per backend, and once in memory for tests.
public protocol AnalyticsTracking: Sendable {
    func track(_ event: AnalyticsEvent)
}

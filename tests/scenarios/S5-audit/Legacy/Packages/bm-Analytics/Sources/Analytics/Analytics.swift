import Foundation

/// The façade the rest of the app calls. It fans one event out to every configured sink, so
/// adding a vendor is a change in the app shell rather than at each call site.
public struct Analytics: Sendable {
    private let sinks: [any AnalyticsTracking]

    public init(sinks: [any AnalyticsTracking] = []) {
        self.sinks = sinks
    }

    public func track(event name: String, parameters: [String: String] = [:]) {
        let event = AnalyticsEvent(name: name, parameters: parameters)
        for sink in sinks {
            sink.track(event)
        }
    }
}

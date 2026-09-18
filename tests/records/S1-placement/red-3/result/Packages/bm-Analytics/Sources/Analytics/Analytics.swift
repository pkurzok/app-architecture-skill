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

    /// The one call every screen makes. A fixed event name and parameter key, so "which screen
    /// appeared" reports the same shape everywhere, no matter how many screens exist.
    public func trackScreenView(_ name: String) {
        track(event: "screen_view", parameters: ["screen": name])
    }
}

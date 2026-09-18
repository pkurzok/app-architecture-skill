import Foundation
import Synchronization

/// A sink that keeps what it was given, so a test can assert on it.
public final class InMemoryAnalyticsSink: AnalyticsTracking {
    private let storage = Mutex<[AnalyticsEvent]>([])

    public init() {}

    public var events: [AnalyticsEvent] {
        storage.withLock { $0 }
    }

    public func track(_ event: AnalyticsEvent) {
        storage.withLock { $0.append(event) }
    }
}

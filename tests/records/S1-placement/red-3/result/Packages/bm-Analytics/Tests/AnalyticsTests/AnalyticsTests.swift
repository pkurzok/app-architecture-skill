import Testing
@testable import Analytics

@Suite("Analytics")
struct AnalyticsTests {

    @Test("An event reaches every sink")
    func eventReachesEverySink() {
        let first = InMemoryAnalyticsSink()
        let second = InMemoryAnalyticsSink()
        let analytics = Analytics(sinks: [first, second])

        analytics.track(event: "book_list_loaded", parameters: ["count": "2"])

        let expected = AnalyticsEvent(name: "book_list_loaded", parameters: ["count": "2"])
        #expect(first.events == [expected])
        #expect(second.events == [expected])
    }

    @Test("Tracking without a sink is harmless")
    func trackingWithoutSinksIsHarmless() {
        Analytics().track(event: "book_list_loaded")
    }

    @Test("A screen view reports its name under a stable event shape")
    func screenViewReportsItsName() {
        let sink = InMemoryAnalyticsSink()
        let analytics = Analytics(sinks: [sink])

        analytics.trackScreenView("BookList")

        #expect(sink.events == [AnalyticsEvent(name: "screen_view", parameters: ["screen": "BookList"])])
    }
}

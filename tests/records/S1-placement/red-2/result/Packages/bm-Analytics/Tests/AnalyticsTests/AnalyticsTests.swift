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

    @Test("A screen reports its own name as a screen_view event")
    func screenAppearedTracksItsName() {
        let sink = InMemoryAnalyticsSink()
        let analytics = Analytics(sinks: [sink])

        analytics.trackScreenAppeared("BookList")

        let expected = AnalyticsEvent(name: "screen_view", parameters: ["screen_name": "BookList"])
        #expect(sink.events == [expected])
    }
}

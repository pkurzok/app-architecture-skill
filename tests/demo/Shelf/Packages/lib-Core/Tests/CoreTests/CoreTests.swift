import Foundation
import Testing
@testable import Core

@Suite("Core")
struct CoreTests {

    @Test("A book id keeps the value it was made from")
    func bookIDKeepsItsValue() {
        #expect(BookID("hobbit").rawValue == "hobbit")
        #expect(BookID("hobbit") == BookID("hobbit"))
    }

    @Test("A publication date renders as its year")
    func publicationYearIsTheYear() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let date = Date(timeIntervalSince1970: 0)
        #expect(PublicationYear.label(for: date, calendar: calendar) == "1970")
    }
}

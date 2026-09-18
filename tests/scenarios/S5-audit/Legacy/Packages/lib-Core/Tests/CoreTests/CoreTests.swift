import Testing
@testable import Core

@Suite("Core")
struct CoreTests {

    @Test("A book id keeps the value it was made from")
    func bookIDKeepsItsValue() {
        #expect(BookID("hobbit").rawValue == "hobbit")
    }
}

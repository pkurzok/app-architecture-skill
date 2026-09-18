import Testing
@testable import Formatting

@Suite("Formatting")
struct FormattingTests {

    @Test("A shelf count reads as a sentence")
    func shelfCountReadsAsASentence() {
        #expect(ShelfCount.label(for: 1) == "1 book")
        #expect(ShelfCount.label(for: 3) == "3 books")
    }
}

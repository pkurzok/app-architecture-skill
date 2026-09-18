import Testing
import NotesKit
@testable import NotesListFeature

@Suite("NotesListView")
@MainActor
struct NotesListViewTests {
    @Test("initializes against a populated store without crashing")
    func initializesWithNotes() {
        let store = NotesStore(
            persistence: InMemoryNotesPersistence(seed: [Note(title: "Existing")])
        )

        _ = NotesListView(store: store)
    }

    @Test("initializes against an empty store without crashing")
    func initializesEmpty() {
        let store = NotesStore(persistence: InMemoryNotesPersistence())

        _ = NotesListView(store: store)
    }
}

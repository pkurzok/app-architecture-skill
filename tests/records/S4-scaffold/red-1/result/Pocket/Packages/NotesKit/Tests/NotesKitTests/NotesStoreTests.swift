import Testing
@testable import NotesKit

@Suite("NotesStore")
@MainActor
struct NotesStoreTests {
    @Test("adding a note inserts it at the top")
    func addNoteInsertsAtTop() {
        let store = NotesStore(persistence: InMemoryNotesPersistence())

        store.addNote(title: "First")
        store.addNote(title: "Second")

        #expect(store.notes.map(\.title) == ["Second", "First"])
    }

    @Test("deleting a note removes it")
    func deleteRemovesNote() {
        let store = NotesStore(persistence: InMemoryNotesPersistence())
        let note = store.addNote(title: "Temp")

        store.delete(note)

        #expect(store.notes.isEmpty)
    }

    @Test("store loads notes from persistence on init")
    func loadsFromPersistence() {
        let seeded = InMemoryNotesPersistence(seed: [Note(title: "Existing")])

        let store = NotesStore(persistence: seeded)

        #expect(store.notes.map(\.title) == ["Existing"])
    }
}

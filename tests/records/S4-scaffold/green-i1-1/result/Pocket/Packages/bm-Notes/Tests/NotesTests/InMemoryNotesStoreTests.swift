import Foundation
import Testing
@testable import Notes

@Suite("InMemoryNotesStore")
struct InMemoryNotesStoreTests {
    @Test("Starts empty when seeded with nothing")
    func startsEmpty() async {
        let store = InMemoryNotesStore()
        #expect(await store.fetchAll().isEmpty)
    }

    @Test("Saves a note and returns it from fetchAll")
    func savesNote() async {
        let store = InMemoryNotesStore()
        let note = Note(title: "Groceries")

        await store.save(note)

        #expect(await store.fetchAll().map(\.id) == [note.id])
    }

    @Test("Saving an existing id replaces it rather than duplicating it")
    func updatesExistingNote() async {
        let store = InMemoryNotesStore()
        var note = Note(title: "Groceries")
        await store.save(note)

        note.title = "Groceries v2"
        await store.save(note)

        let all = await store.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.title == "Groceries v2")
    }

    @Test("Deletes a note by id")
    func deletesNote() async {
        let store = InMemoryNotesStore()
        let note = Note(title: "Groceries")
        await store.save(note)

        await store.delete(id: note.id)

        #expect(await store.fetchAll().isEmpty)
    }

    @Test("Orders notes by most recently updated first")
    func ordersByUpdatedAt() async {
        let store = InMemoryNotesStore()
        let older = Note(title: "Older", updatedAt: Date(timeIntervalSince1970: 0))
        let newer = Note(title: "Newer", updatedAt: Date(timeIntervalSince1970: 100))

        await store.save(older)
        await store.save(newer)

        #expect(await store.fetchAll().map(\.title) == ["Newer", "Older"])
    }
}

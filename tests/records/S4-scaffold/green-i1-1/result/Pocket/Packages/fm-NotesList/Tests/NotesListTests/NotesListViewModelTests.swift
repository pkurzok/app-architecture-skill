import Foundation
import Notes
import Testing
@testable import NotesList

@MainActor
@Suite("NotesListViewModel")
struct NotesListViewModelTests {
    @Test("Loading reads every note from the store")
    func loadReadsFromStore() async {
        let store = InMemoryNotesStore(seed: [Note(title: "Groceries")])
        let viewModel = NotesListViewModel(store: store)

        await viewModel.load()

        #expect(viewModel.notes.map(\.title) == ["Groceries"])
    }

    @Test("Adding a note saves it and refreshes the list")
    func addNoteRefreshesList() async {
        let viewModel = NotesListViewModel(store: InMemoryNotesStore())

        await viewModel.addNote(titled: "Walk the dog")

        #expect(viewModel.notes.map(\.title) == ["Walk the dog"])
    }

    @Test("Adding a blank title is a no-op")
    func addBlankTitleDoesNothing() async {
        let viewModel = NotesListViewModel(store: InMemoryNotesStore())

        await viewModel.addNote(titled: "   ")

        #expect(viewModel.notes.isEmpty)
    }

    @Test("Deleting an offset removes the matching note")
    func deleteRemovesNote() async {
        let store = InMemoryNotesStore()
        let viewModel = NotesListViewModel(store: store)
        await viewModel.addNote(titled: "Keep")
        await viewModel.addNote(titled: "Remove")

        let indexToRemove = viewModel.notes.firstIndex { $0.title == "Remove" }!
        await viewModel.delete(at: IndexSet(integer: indexToRemove))

        #expect(viewModel.notes.map(\.title) == ["Keep"])
    }
}

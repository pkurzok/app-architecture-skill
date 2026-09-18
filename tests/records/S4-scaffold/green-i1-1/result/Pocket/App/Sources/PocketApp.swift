import Notes
import NotesList
import SwiftUI

/// The composition root: the one place allowed to import every layer. It builds the concrete
/// store and hands it to the feature, which knows only the ``NotesStore`` protocol.
@main
struct PocketApp: App {
    private let notesStore = InMemoryNotesStore()

    var body: some Scene {
        WindowGroup {
            NotesListView(viewModel: NotesListViewModel(store: notesStore))
        }
    }
}

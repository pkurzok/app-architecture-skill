import SwiftUI
import NotesKit
import NotesListFeature

/// Composition root: the app target only wires the feature and
/// its store together. All behavior lives in the local packages.
@main
struct PocketApp: App {
    @State private var notesStore = NotesStore()

    var body: some Scene {
        WindowGroup {
            NotesListView(store: notesStore)
        }
    }
}

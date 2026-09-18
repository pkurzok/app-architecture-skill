import Foundation
import Observation

/// The reader's choices about the shelf. One instance is built by the app shell and shared by
/// everything that reads or changes it.
@MainActor
@Observable
public final class CatalogSettings {
    public var sortOrder: BookSortOrder

    public init(sortOrder: BookSortOrder = .title) {
        self.sortOrder = sortOrder
    }
}

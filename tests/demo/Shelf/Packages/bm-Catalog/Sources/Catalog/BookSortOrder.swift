import Foundation

/// How the shelf is ordered. Named for books rather than `SortOrder`, which Foundation already has.
public enum BookSortOrder: String, CaseIterable, Sendable {
    case title
    case author

    /// What to call this order in a picker. A string is not a view, so it stays here with the
    /// domain rather than travelling to the feature as a magic constant.
    public var label: String {
        switch self {
        case .title: "Title"
        case .author: "Author"
        }
    }
}

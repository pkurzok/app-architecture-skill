import Foundation

/// A book's identity, wrapped so a raw `String` can never be passed where an id is meant.
public struct BookID: Hashable, Sendable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

import Core
import Foundation

/// One book on the shelf.
public struct Book: Identifiable, Hashable, Sendable {
    public let id: BookID
    public let title: String
    public let author: String
    public let published: Date

    public init(id: BookID, title: String, author: String, published: Date) {
        self.id = id
        self.title = title
        self.author = author
        self.published = published
    }
}

public extension Book {
    /// The shelf every fresh install starts with.
    static let sample: [Book] = [
        Book(id: BookID("dune"), title: "Dune", author: "Frank Herbert",
             published: Date(timeIntervalSince1970: -139_449_600)),
        Book(id: BookID("kindred"), title: "Kindred", author: "Octavia E. Butler",
             published: Date(timeIntervalSince1970: 283_996_800)),
        Book(id: BookID("zone-one"), title: "Zone One", author: "Colson Whitehead",
             published: Date(timeIntervalSince1970: 1_318_896_000)),
    ]
}

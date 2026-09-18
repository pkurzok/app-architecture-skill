import Foundation

/// A single note: a title, its body text, and when it was last touched.
public struct Note: Identifiable, Equatable, Sendable, Codable {
    public let id: UUID
    public var title: String
    public var body: String
    public var updatedAt: Date

    public init(id: UUID = UUID(), title: String, body: String = "", updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.body = body
        self.updatedAt = updatedAt
    }
}

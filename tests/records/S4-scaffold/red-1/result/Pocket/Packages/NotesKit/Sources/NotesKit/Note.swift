import Foundation

/// A single note. Plain, `Sendable` value type so it can cross
/// actor boundaries (store -> view) without ceremony.
public struct Note: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var body: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        body: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

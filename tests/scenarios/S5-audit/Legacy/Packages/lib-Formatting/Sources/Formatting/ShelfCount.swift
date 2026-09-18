import Foundation

/// Renders "3 books" / "1 book".
public enum ShelfCount {
    public static func label(for count: Int) -> String {
        count == 1 ? "1 book" : "\(count) books"
    }
}

import UIKit

/// The colour a cover placeholder is drawn in, derived from the book's id so the same book
/// always gets the same colour.
public enum CoverTint {
    private static let palette: [UIColor] = [.systemTeal, .systemIndigo, .systemOrange]

    public static func color(for id: BookID) -> UIColor {
        palette[abs(id.rawValue.hashValue) % palette.count]
    }
}

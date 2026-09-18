import Foundation

/// Renders a publication date as the year alone. Domain-agnostic on purpose: it knows about
/// dates, not about books, which is what keeps it in the Library layer.
public enum PublicationYear {
    public static func label(for date: Date, calendar: Calendar = .current) -> String {
        String(calendar.component(.year, from: date))
    }
}

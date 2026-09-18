import SwiftUI

/// The rounded container every list row sits in.
public struct CardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(Spacing.medium)
            .background(.background.secondary, in: .rect(cornerRadius: Spacing.medium))
    }
}

public extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

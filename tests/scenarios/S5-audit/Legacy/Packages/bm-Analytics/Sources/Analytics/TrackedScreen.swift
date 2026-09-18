import SwiftUI

/// Reports a screen view when the screen appears.
public struct TrackedScreen: ViewModifier {
    private let name: String
    private let analytics: Analytics

    public init(name: String, analytics: Analytics) {
        self.name = name
        self.analytics = analytics
    }

    public func body(content: Content) -> some View {
        content.onAppear {
            analytics.track(event: "screen_view", parameters: ["screen": name])
        }
    }
}

public extension View {
    func trackScreen(_ name: String, analytics: Analytics) -> some View {
        modifier(TrackedScreen(name: name, analytics: analytics))
    }
}

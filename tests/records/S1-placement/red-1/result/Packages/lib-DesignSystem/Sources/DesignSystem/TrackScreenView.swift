import Core
import SwiftUI

public extension View {
    /// Reports this screen's name the moment it appears, and again each time it comes back. Every
    /// screen gets this same one line, so wiring up the next one is never more than that.
    func trackScreenView(_ name: String, using tracker: some ScreenViewTracking) -> some View {
        onAppear { tracker.trackScreenView(name) }
    }
}

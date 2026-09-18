import Core
import Foundation

/// Adopts the screen-tracking contract a UI library can call without depending on Analytics
/// itself. Screen-view events all share this shape, so every screen's tracking looks the same.
extension Analytics: ScreenViewTracking {
    public func trackScreenView(_ name: String) {
        track(event: "screen_view", parameters: ["screen": name])
    }
}

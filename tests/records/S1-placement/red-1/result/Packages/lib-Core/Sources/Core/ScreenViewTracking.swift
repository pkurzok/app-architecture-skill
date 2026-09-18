import Foundation

/// Something that can be told a screen appeared. `Analytics` conforms to this (in bm-Analytics),
/// but the protocol lives here — in a UI-free library both a feature and a business module can
/// see — so a UI library can offer a screen-tracking view modifier without depending on Analytics
/// itself, and a business module can adopt it without depending on SwiftUI.
public protocol ScreenViewTracking: Sendable {
    func trackScreenView(_ name: String)
}

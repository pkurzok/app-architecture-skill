import SwiftUI

public extension View {
    /// Reports that this screen appeared. Every screen adds this one modifier, passing its own
    /// name and however it reports it — the view never needs to know what "reporting" means.
    func trackScreenView(_ name: String, track: @escaping (String) -> Void) -> some View {
        onAppear { track(name) }
    }
}

import Foundation

/// The deny-list behind the golden rule: a business module renders nothing, so it imports none of
/// these.
///
/// Mixed frameworks (MapKit, StoreKit, WidgetKit, AVFoundation) are deliberately absent. Their
/// non-UI half is legitimate business code, so they are a judgement call for a human, not a gate.
enum UIFrameworks {
    static let builtIn: Set<String> = [
        "AVKit",
        "AppKit",
        "CarPlay",
        "Charts",
        "ContactsUI",
        "EventKitUI",
        "MessageUI",
        "PencilKit",
        "PhotosUI",
        "QuickLook",
        "QuickLookUI",
        "SafariServices",
        "SwiftUI",
        "TVUIKit",
        "TipKit",
        "UIKit",
        "WatchKit",
        "WebKit",
    ]

    /// The built-in list plus whatever this project added.
    static func all() -> Set<String> {
        builtIn.union(ArchitectureConfig.extraUIFrameworks)
    }
}

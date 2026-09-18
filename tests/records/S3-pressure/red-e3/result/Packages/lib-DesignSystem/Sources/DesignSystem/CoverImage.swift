#if canImport(UIKit)
import Core
import UIKit

/// Decoded cover thumbnails, kept so a scrolling shelf never decodes the same cover twice.
///
/// Rendering belongs in the design system, not in Catalog: a business module holds domain logic
/// and stays UI-free, so image rendering for the shelf lives here instead.
@MainActor
public final class CoverImageCache {
    public static let shared = CoverImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    public func thumbnail(for id: BookID, size: CGSize) -> UIImage {
        if let cached = cache.object(forKey: id.rawValue as NSString) {
            return cached
        }
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.secondarySystemFill.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.tertiaryLabel.setFill()
            context.fill(CGRect(x: 0, y: size.height - 4, width: size.width, height: 4))
        }
        cache.setObject(image, forKey: id.rawValue as NSString)
        return image
    }
}
#endif

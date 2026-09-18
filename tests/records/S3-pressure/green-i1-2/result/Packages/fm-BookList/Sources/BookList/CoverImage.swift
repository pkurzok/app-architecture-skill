import Core
import UIKit

/// Decoded cover thumbnails, kept so a scrolling shelf never decodes the same cover twice.
///
/// Lives here rather than in Catalog: it renders pixels, and Business renders nothing.
@MainActor
final class CoverImageCache {
    static let shared = CoverImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func thumbnail(for id: BookID, size: CGSize) -> UIImage {
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

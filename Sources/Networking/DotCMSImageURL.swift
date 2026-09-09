import Foundation
import UIKit

/// Builds dotCMS asset URLs sized for the view that will display them.
///
/// Verified against dotCMS on 2026-09-09:
///  - `/dA/{identifier}/{field}/{name}` serves the ORIGINAL asset. The demo
///    blog images are 5184x3456 / 2.2 MB — never load these directly.
///  - Appending `{width}w` resizes, but returns PNG (768 KB).
///  - Appending a quality parameter (`{n}q`) switches the pipeline to WebP:
///    `/dA/{id}/image/800w/80q` is 18 KB — a ~124x reduction. iOS 17 decodes
///    WebP natively, so AsyncImage handles it without a third-party decoder.
///
/// GraphQL `DotBinary.path` returns a sharded path
/// (`7/d/7d310d79-.../image/x.jpg`) while the Page API returns `/dA/{id}/...`.
/// Both resolve, but only the `/dA/` form accepts resize parameters, so the
/// identifier-based form is always preferred and `path` is the fallback.
enum DotCMSImageURL {
    /// JPEG/WebP quality for resized assets. 80 is visually lossless at
    /// phone sizes and keeps payloads tiny.
    static let defaultQuality = 80

    /// Builds a resized asset URL.
    ///
    /// - Parameters:
    ///   - identifier: contentlet identifier (preferred).
    ///   - fieldName: binary field variable, e.g. `image`.
    ///   - fallbackPath: `DotBinary.path`, used when no identifier is known.
    ///   - width: target width in POINTS; multiplied by the screen scale.
    static func url(
        identifier: String?,
        fieldName: String = "image",
        fallbackPath: String? = nil,
        width: CGFloat?,
        quality: Int = defaultQuality,
        languageID: String? = nil,
        config: AppConfig = .shared
    ) -> URL? {
        var relative: String

        if let identifier, !identifier.isEmpty {
            relative = "/dA/\(identifier)/\(fieldName)"
            if let width, width > 0 {
                let pixels = Int((width * UIScreen.main.scale).rounded())
                relative += "/\(pixels)w/\(quality)q"
            }
        } else if let fallbackPath, !fallbackPath.isEmpty {
            // Sharded path from DotBinary.path. Resize params are not
            // reliable on this form, so it is served as-is.
            relative = fallbackPath.hasPrefix("/") ? fallbackPath : "/\(fallbackPath)"
        } else {
            return nil
        }

        guard var components = URLComponents(
            url: config.host.appendingPathComponent(
                relative.hasPrefix("/") ? String(relative.dropFirst()) : relative
            ),
            resolvingAgainstBaseURL: false
        ) else { return nil }

        if let languageID {
            components.queryItems = [URLQueryItem(name: "language_id", value: languageID)]
        }
        return components.url
    }

    /// Convenience for a contentlet whose binary field is already known.
    static func url(
        for contentlet: Contentlet,
        fieldName: String = "image",
        width: CGFloat?
    ) -> URL? {
        url(
            identifier: contentlet.identifier,
            fieldName: fieldName,
            fallbackPath: contentlet.imagePath,
            width: width
        )
    }
}

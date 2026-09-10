import Foundation

/// A single piece of dotCMS content, normalised for the UI layer.
///
/// EVERY content field is optional, deliberately, even where the GraphQL
/// schema declares non-null (`Blog.urlTitle` is `String!` today). Content
/// types are edited by authors at runtime; a field that is required this
/// morning can be gone this afternoon. Views render a placeholder or omit
/// the row rather than crashing.
struct Contentlet: Identifiable, Hashable, Sendable {
    /// dotCMS content type variable name — the registry key.
    let contentType: String

    let identifier: String?
    let inode: String?
    let title: String?
    let urlTitle: String?
    let summary: String?
    let publishDate: Date?
    let link: String?
    let buttonText: String?
    let authorName: String?
    let imagePath: String?
    let imageWidth: Int?
    let imageHeight: Int?

    /// StoryBlock body, kept as raw JSON for `StoryBlockRenderer`.
    let body: StoryBlock?

    /// Fields not mapped above, so an unknown type can still show something.
    let extra: [String: String]

    /// Stable across accesses. A fresh UUID() here would give SwiftUI a new
    /// identity on every render pass, breaking ForEach diffing and animations
    /// for any contentlet whose identifier and inode were both stripped.
    var id: String {
        if let identifier, !identifier.isEmpty { return identifier }
        if let inode, !inode.isEmpty { return inode }
        return "\(contentType)-\(title ?? "")-\(urlTitle ?? "")"
    }

    /// Title safe to display; never empty.
    var displayTitle: String {
        let t = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (t?.isEmpty == false) ? t! : "Untitled"
    }

    /// Aspect ratio of the hero image when dotCMS reported both dimensions.
    var imageAspectRatio: CGFloat? {
        guard let w = imageWidth, let h = imageHeight, w > 0, h > 0 else { return nil }
        return CGFloat(w) / CGFloat(h)
    }
}

import Foundation

/// dotCMS server-side GraphQL cache control, sent as request headers.
///
/// `.demo` is the default and deliberately so: when content is edited in
/// dotCMS during a live demo it must appear on the next pull-to-refresh.
/// A stale response makes the demo look broken.
enum CachePolicy: String, CaseIterable, Identifiable, Sendable {
    case demo
    case production

    var id: String { rawValue }

    /// `dotcachettl` — cache expiration in seconds.
    var ttlSeconds: Int {
        switch self {
        case .demo: 1
        case .production: 300
        }
    }

    var displayName: String {
        switch self {
        case .demo: "Demo (1s)"
        case .production: "Production (300s)"
        }
    }

    var explanation: String {
        switch self {
        case .demo:
            "Content edits appear on the next refresh. Use while demoing authoring."
        case .production:
            "Responses cached server-side for 5 minutes. Use to show the performance story."
        }
    }
}

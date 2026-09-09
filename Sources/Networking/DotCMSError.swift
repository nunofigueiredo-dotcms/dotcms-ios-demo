import Foundation

/// Errors surfaced to the UI, each with a message that is safe and useful to
/// read aloud during a demo.
enum DotCMSError: LocalizedError, Equatable {
    case notConfigured(String)
    case unauthorized
    case network(String)
    case graphQL([String])
    case decoding(String)
    case notFound

    var errorDescription: String? {
        switch self {
        case .notConfigured(let detail):
            "Not configured: \(detail)"
        case .unauthorized:
            "dotCMS rejected the API token (401). It may have expired."
        case .network(let detail):
            "Could not reach dotCMS: \(detail)"
        case .graphQL(let messages):
            messages.first ?? "GraphQL error"
        case .decoding(let detail):
            "Unexpected response shape: \(detail)"
        case .notFound:
            "That content was not found."
        }
    }

    /// Shown under the headline in error states — tells the presenter what to do.
    var recoverySuggestion: String? {
        switch self {
        case .notConfigured:
            """
            Set DOTCMS_AUTH_TOKEN in the Xcode scheme:
            Product > Scheme > Edit Scheme > Run > Arguments >
            Environment Variables.

            Generate a token in dotCMS under
            System > Users > admin > API Access Tokens.
            """
        case .unauthorized:
            "Generate a new API token and update the scheme environment variable."
        case .network:
            "Confirm dotCMS is running and reachable from this device."
        case .graphQL:
            "A content type may have changed. Run Scripts/check-schema-drift.sh."
        case .decoding, .notFound:
            nil
        }
    }
}

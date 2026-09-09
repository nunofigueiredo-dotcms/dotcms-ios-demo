import Foundation

/// Runtime configuration loaded from the gitignored `Config.plist`.
///
/// Falls back to Info.plist keys so the app can also be configured from an
/// xcconfig without a Config.plist present.
struct AppConfig: Sendable {
    let host: URL
    let siteID: String
    let siteName: String
    let languageID: String

    static let shared: AppConfig = load()

    /// GraphQL endpoint for the configured host.
    var graphQLURL: URL { host.appendingPathComponent("api/v1/graphql") }

    private static func load() -> AppConfig {
        let values = plistValues()

        let rawHost = values["DOTCMS_HOST"] ?? ""
        guard let url = URL(string: rawHost), url.scheme != nil else {
            // A misconfigured host must fail loudly at launch rather than
            // producing confusing network errors on every screen.
            fatalError(
                """
                DOTCMS_HOST is missing or invalid ("\(rawHost)").
                Copy Config.example.plist to Config.plist and fill it in.
                """
            )
        }

        return AppConfig(
            host: url,
            siteID: values["DOTCMS_SITE_ID"] ?? "",
            siteName: values["DOTCMS_SITE_NAME"] ?? "",
            languageID: values["DOTCMS_LANGUAGE_ID"] ?? "1"
        )
    }

    private static func plistValues() -> [String: String] {
        if let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let dict = try? PropertyListSerialization.propertyList(
               from: data, format: nil
           ) as? [String: Any] {
            return dict.compactMapValues { $0 as? String }
        }
        // Fallback: Info.plist entries driven by an xcconfig.
        let keys = [
            "DOTCMS_HOST", "DOTCMS_SITE_ID", "DOTCMS_SITE_NAME", "DOTCMS_LANGUAGE_ID",
        ]
        return keys.reduce(into: [:]) { result, key in
            if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String {
                result[key] = value
            }
        }
    }
}

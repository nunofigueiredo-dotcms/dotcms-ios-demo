import CryptoKit
import Foundation

/// Hash of the GraphQL schema the app's models were generated from.
///
/// Shown in Settings so that during a demo it is possible to confirm the app
/// matches the instance, and it is generated at build time by
/// Scripts/stamp-schema-hash.sh.
enum SchemaInfo {
    static var fullHash: String {
        (Bundle.main.object(forInfoDictionaryKey: "DOTCMS_SCHEMA_SHA") as? String)
            ?? "unknown"
    }

    static var shortHash: String {
        let hash = fullHash
        return hash == "unknown" ? hash : String(hash.prefix(12))
    }
}

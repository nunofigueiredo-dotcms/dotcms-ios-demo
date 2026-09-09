import Foundation
import Security

/// Keychain-backed storage for the dotCMS API token.
///
/// The token is never compiled into the binary and never written to a tracked
/// file. On first launch it is seeded from the `DOTCMS_AUTH_TOKEN` scheme
/// environment variable, then persisted to the Keychain so subsequent launches
/// work without the variable set.
enum TokenStore {
    private static let service = "com.dotcms.demo.ios"
    private static let account = "dotcms-auth-token"

    enum TokenError: LocalizedError {
        case missing

        var errorDescription: String? {
            """
            No dotCMS API token found.

            Set DOTCMS_AUTH_TOKEN in the Xcode scheme:
            Product > Scheme > Edit Scheme > Run > Arguments >
            Environment Variables.

            The token is read once and stored in the Keychain.
            """
        }
    }

    /// Returns the token, seeding the Keychain from the environment if needed.
    static func token() throws -> String {
        if let seeded = ProcessInfo.processInfo.environment["DOTCMS_AUTH_TOKEN"],
           !seeded.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let value = seeded.trimmingCharacters(in: .whitespacesAndNewlines)
            try? save(value)
            return value
        }
        guard let stored = read() else { throw TokenError.missing }
        return stored
    }

    /// True when a token is available from either source, without throwing.
    static var isConfigured: Bool {
        (try? token()) != nil
    }

    static func save(_ token: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)

        var insert = query
        insert[kSecValueData as String] = data
        insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(insert as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    static func read() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return nil }
        return value
    }

    static func clear() {
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ] as CFDictionary)
    }

    /// Safe for display in Settings — never shows the token itself.
    static var redactedDescription: String {
        guard let t = read() else { return "not set" }
        return "stored (\(t.count) chars, ending …\(t.suffix(4)))"
    }
}

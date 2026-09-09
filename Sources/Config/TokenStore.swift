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

    /// In-memory fallback for when the Keychain is unavailable.
    ///
    /// A simulator build signed without entitlements cannot use the Keychain
    /// at all: every SecItemAdd fails with errSecMissingEntitlement (-34018).
    /// Holding the seeded value for the process lifetime means the app still
    /// works in that case instead of dead-ending on "no API token".
    private nonisolated(unsafe) static var cached: String?

    /// Set when a Keychain write failed, so Settings can say so plainly
    /// rather than leaving the token silently unpersisted.
    private nonisolated(unsafe) static var keychainFailure: OSStatus?

    /// Returns the token, seeding the Keychain from the environment if needed.
    static func token() throws -> String {
        if let seeded = ProcessInfo.processInfo.environment["DOTCMS_AUTH_TOKEN"],
           !seeded.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let value = seeded.trimmingCharacters(in: .whitespacesAndNewlines)
            cached = value
            do {
                try save(value)
                keychainFailure = nil
            } catch let error as NSError {
                // Keep going: the in-memory value is enough for this launch.
                keychainFailure = OSStatus(error.code)
            }
            return value
        }
        if let cached { return cached }
        guard let stored = read() else { throw TokenError.missing }
        cached = stored
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

    /// True when the token could not be persisted to the Keychain.
    static var isEphemeral: Bool { keychainFailure != nil || read() == nil }

    static func clear() {
        cached = nil
        keychainFailure = nil
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ] as CFDictionary)
    }

    /// Safe for display in Settings — never shows the token itself.
    static var redactedDescription: String {
        guard let t = (try? token()) else { return "not set" }
        let suffix = "\(t.count) chars, ending …\(t.suffix(4))"
        if let status = keychainFailure {
            // Surfaced rather than hidden: the token works for this launch but
            // will not survive a relaunch without the scheme variable.
            return "in memory only (\(suffix)) — Keychain error \(status)"
        }
        return read() == nil ? "in memory only (\(suffix))" : "stored (\(suffix))"
    }
}

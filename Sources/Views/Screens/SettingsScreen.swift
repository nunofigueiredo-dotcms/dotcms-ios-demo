import SwiftUI

/// Demo control surface: confirm the target instance, flip the cache TTL,
/// force a refresh, and show the committed schema hash.
struct SettingsScreen: View {
    @AppStorage("cachePolicy") private var cachePolicyRaw = CachePolicy.demo.rawValue
    @State private var lastRefresh: Date?

    private var policy: CachePolicy {
        CachePolicy(rawValue: cachePolicyRaw) ?? .demo
    }

    var body: some View {
        Form {
            Section("Instance") {
                LabeledContent("Host", value: AppConfig.shared.host.absoluteString)
                LabeledContent("Site", value: AppConfig.shared.siteName)
                LabeledContent("Site ID", value: AppConfig.shared.siteID)
                    .font(.caption.monospaced())
                LabeledContent("Language", value: AppConfig.shared.languageID)
            }

            Section {
                Picker("Cache TTL", selection: $cachePolicyRaw) {
                    ForEach(CachePolicy.allCases) { policy in
                        Text(policy.displayName).tag(policy.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                Text(policy.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("GraphQL cache")
            } footer: {
                Text("Sent as the dotcachettl header on every GraphQL request.")
            }

            Section("Schema") {
                LabeledContent("Committed hash", value: SchemaInfo.shortHash)
                    .font(.caption.monospaced())
                LabeledContent("Token", value: TokenStore.redactedDescription)
                    .font(.caption)
            }

            Section {
                Button("Force refresh") {
                    URLCache.shared.removeAllCachedResponses()
                    lastRefresh = .now
                }
                if let lastRefresh {
                    Text("Cleared \(lastRefresh, format: .dateTime.hour().minute().second())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .onChange(of: cachePolicyRaw) { _, new in
            DotCMSClient.cachePolicy = CachePolicy(rawValue: new) ?? .demo
        }
        .onAppear { DotCMSClient.cachePolicy = policy }
    }
}

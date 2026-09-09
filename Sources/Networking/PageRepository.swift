import Foundation

/// Fetches and decodes dotCMS page assets.
///
/// The Page API is used rather than GraphQL because the layout (rows,
/// columns, containers) is not exposed through the GraphQL schema on this
/// instance. Decoding is defensive throughout: a page whose shape changes
/// yields fewer rows, never a crash.
@MainActor
struct PageRepository {
    private let config: AppConfig

    init(config: AppConfig = .shared) {
        self.config = config
    }

    func page(uri: String = "/index") async throws -> PageLayout {
        guard var components = URLComponents(
            url: config.host.appendingPathComponent("api/v1/page/json\(uri)"),
            resolvingAgainstBaseURL: false
        ) else {
            throw DotCMSError.notConfigured("invalid host")
        }
        components.queryItems = [
            URLQueryItem(name: "language_id", value: config.languageID),
            URLQueryItem(name: "mode", value: "LIVE"),
        ]
        if !config.siteID.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "host_id", value: config.siteID))
        }
        guard let url = components.url else {
            throw DotCMSError.notConfigured("invalid page URL")
        }

        // Use token(), not read(): on a fresh install the Keychain is empty
        // and the token must first be seeded from the scheme environment
        // variable. read() alone fails on first launch.
        guard let token = try? TokenStore.token() else {
            throw DotCMSError.notConfigured("no API token")
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // The same server-side cache control used for GraphQL, so the
        // Settings toggle governs the whole app consistently.
        request.setValue(
            String(DotCMSClient.cachePolicy.ttlSeconds), forHTTPHeaderField: "dotcachettl"
        )
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            throw DotCMSError.unauthorized
        }
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw DotCMSError.network("page request failed (HTTP \(code))")
        }

        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let entity = root["entity"] as? [String: Any]
        else {
            throw DotCMSError.decoding("unexpected page response")
        }
        return Self.decode(entity: entity)
    }

    // MARK: - Decoding

    static func decode(entity: [String: Any]) -> PageLayout {
        let page = entity["page"] as? [String: Any]
        let containers = entity["containers"] as? [String: Any] ?? [:]
        let rawRows = ((entity["layout"] as? [String: Any])?["body"]
            as? [String: Any])?["rows"] as? [[String: Any]] ?? []

        let rows = rawRows.enumerated().map { rowIndex, rawRow in
            let rawColumns = rawRow["columns"] as? [[String: Any]] ?? []
            let columns = rawColumns.enumerated().map { columnIndex, rawColumn in
                PageLayout.Column(
                    id: "\(rowIndex)-\(columnIndex)",
                    width: rawColumn["width"] as? Int ?? 12,
                    contentlets: contentlets(in: rawColumn, containers: containers)
                )
            }
            return PageLayout.Row(id: rowIndex, columns: columns)
        }

        return PageLayout(title: page?["title"] as? String, rows: rows)
    }

    /// Resolves a column's container references into their contentlets.
    ///
    /// Contentlets live under `containers[id].contentlets["uuid-N"]`, keyed by
    /// the uuid the column references — not inline in the column itself.
    private static func contentlets(
        in column: [String: Any],
        containers: [String: Any]
    ) -> [Contentlet] {
        let refs = column["containers"] as? [[String: Any]] ?? []
        return refs.flatMap { ref -> [Contentlet] in
            guard
                let identifier = ref["identifier"] as? String,
                let container = containers[identifier] as? [String: Any],
                let byUUID = container["contentlets"] as? [String: Any]
            else { return [] }

            // `uuid` is sometimes a string and sometimes an array of strings.
            let uuids: [String]
            switch ref["uuid"] {
            case let single as String: uuids = [single]
            case let many as [String]: uuids = many
            case let many as [Any]: uuids = many.compactMap { $0 as? String }
            default: uuids = []
            }

            return uuids.flatMap { uuid -> [Contentlet] in
                let raw = byUUID["uuid-\(uuid)"] as? [[String: Any]] ?? []
                return raw.map(contentlet(from:))
            }
        }
    }

    /// Maps a raw Page API contentlet. Every field is optional by design.
    static func contentlet(from raw: [String: Any]) -> Contentlet {
        let string: (String) -> String? = { raw[$0] as? String }

        var extra: [String: String] = [:]
        for (key, value) in raw {
            if let text = value as? String, text.count < 400 {
                extra[key] = text
            }
        }

        return Contentlet(
            contentType: string("contentType") ?? "Unknown",
            identifier: string("identifier"),
            inode: string("inode"),
            title: string("title"),
            urlTitle: string("urlTitle"),
            summary: string("description") ?? string("caption") ?? string("teaser"),
            publishDate: date(from: raw["publishDate"]),
            link: string("link") ?? string("urlMap") ?? string("URL_MAP_FOR_CONTENT"),
            buttonText: string("buttonText"),
            authorName: nil,
            // The Page API returns "/dA/{id}/image/{name}"; the URL builder
            // prefers the identifier, so this is only ever a fallback.
            imagePath: string("image"),
            imageWidth: nil,
            imageHeight: nil,
            body: StoryBlock(json: raw["body"]),
            extra: extra
        )
    }

    private static func date(from value: Any?) -> Date? {
        if let millis = value as? Double {
            return Date(timeIntervalSince1970: millis / 1000)
        }
        if let millis = value as? Int {
            return Date(timeIntervalSince1970: Double(millis) / 1000)
        }
        return ContentRepository.parseDate(value as? String)
    }
}

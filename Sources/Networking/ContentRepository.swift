import Foundation

/// Maps generated Apollo models into the app's `Contentlet`.
///
/// This is the only place that touches generated types. Everything above it
/// works with `Contentlet`, whose fields are all optional, so a content-type
/// change surfaces here as a nil rather than propagating a crash into a view.
@MainActor
struct ContentRepository {
    private let client: DotCMSClient

    init(client: DotCMSClient? = nil) {
        self.client = client ?? .shared
    }

    // MARK: - Dates

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static func parseDate(_ raw: String?) -> Date? {
        guard let raw, !raw.isEmpty else { return nil }
        if let d = iso8601.date(from: raw) { return d }
        // dotCMS also returns "2026-02-17 09:16:00.0" style values.
        let fallback = DateFormatter()
        fallback.locale = Locale(identifier: "en_US_POSIX")
        fallback.timeZone = TimeZone(identifier: "UTC")
        for format in [
            "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss.S",
            "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd",
        ] {
            fallback.dateFormat = format
            if let d = fallback.date(from: raw) { return d }
        }
        return nil
    }

    /// dotCMS declares image width/height as the `Long` scalar, which Apollo
    /// generates as `String`. Parse defensively rather than assuming a number.
    private static func int(_ raw: String?) -> Int? {
        guard let raw, !raw.isEmpty else { return nil }
        return Int(raw) ?? Int(Double(raw) ?? .nan)
    }

    // MARK: - Blog

    func blogs(limit: Int = 20, offset: Int = 0) async throws -> [Contentlet] {
        let data = try await client.fetch(
            DotCMSAPI.BlogListQuery(limit: limit, offset: offset, query: client.siteFilter)
        )
        let sorted = (data.blogCollection ?? [])
            .compactMap { $0?.fragments.blogFields }
            .map { Self.contentlet(from: $0, bodyJSON: nil) }
        if !sorted.isEmpty { return sorted }

        // A sortBy naming a field the index cannot sort returns ZERO results
        // with no GraphQL error — indistinguishable from "no content". Retry
        // unsorted so a demo degrades to unordered posts instead of a blank
        // screen, and sort client-side by the date we already have.
        let unsorted = try await client.fetch(
            DotCMSAPI.BlogListUnsortedQuery(limit: limit, offset: offset, query: client.siteFilter)
        )
        return (unsorted.blogCollection ?? [])
            .compactMap { $0?.fragments.blogFields }
            .map { Self.contentlet(from: $0, bodyJSON: nil) }
            .sorted { ($0.publishDate ?? .distantPast) > ($1.publishDate ?? .distantPast) }
    }

    func blog(urlTitle: String) async throws -> Contentlet {
        // Lucene field filters must be type-qualified, exactly like sortBy.
        let query = "\(client.siteFilter) +Blog.urlTitle:\(urlTitle)"
            .trimmingCharacters(in: .whitespaces)
        let data = try await client.fetch(DotCMSAPI.BlogDetailQuery(query: query))
        guard let first = (data.blogCollection ?? []).compactMap({ $0 }).first else {
            throw DotCMSError.notFound
        }
        // Read the body defensively. Apollo's generated getter force-casts the
        // stored value, so anything unexpected there is a crash, not a nil —
        // pull the raw dictionary out of __data instead of trusting the getter.
        return Self.contentlet(
            from: first.fragments.blogFields,
            bodyJSON: Self.storyBlockJSON(from: first)
        )
    }

    /// Extracts the StoryBlock body without going through the generated
    /// force-casting accessor.
    ///
    /// `DataDict`'s subscript does `_data[key] as! T`, so any value it did not
    /// expect aborts the process instead of returning nil. Reading the
    /// underlying storage directly keeps a surprising shape recoverable.
    private static func storyBlockJSON(
        from blog: DotCMSAPI.BlogDetailQuery.Data.BlogCollection
    ) -> Any? {
        let storage: [String: AnyHashable] = blog.__data._data
        guard let bodyValue = storage["body"] else { return nil }

        // `body` is itself a selection set, stored as its own dictionary.
        let bodyDict: [String: AnyHashable]?
        if let dict = bodyValue.base as? [String: AnyHashable] {
            bodyDict = dict
        } else if let nested = bodyValue.base as? DataDict {
            bodyDict = nested._data
        } else {
            bodyDict = nil
        }

        guard let json = bodyDict?["json"] else { return nil }
        if let scalar = json.base as? DotCMSAPI.JSON { return scalar.jsonObject }
        return DotCMSAPI.JSON.unwrapValue(json)
    }

    // MARK: - Mapping

    private static func contentlet(
        from blog: DotCMSAPI.BlogFields,
        bodyJSON: Any?
    ) -> Contentlet {
        let image = blog.image
        return Contentlet(
            contentType: "Blog",
            identifier: blog.identifier,
            inode: blog.inode,
            title: blog.title,
            // Non-null in the schema today, but treated as optional per the
            // nullability rule: an author can delete this field tomorrow.
            urlTitle: blog.urlTitle,
            summary: blog.description,
            publishDate: parseDate(blog.publishDate),
            link: blog.urlMap,
            buttonText: nil,
            authorName: blog.author?.compactMap { $0?.title }.first,
            imagePath: image?.path,
            imageWidth: int(image?.width),
            imageHeight: int(image?.height),
            body: StoryBlock(json: bodyJSON),
            extra: [:]
        )
    }
}

import Foundation

/// dotCMS StoryBlock content.
///
/// `Blog.body` and `webPageContent.body` are NOT html — they are ProseMirror
/// style JSON documents: `{"type":"doc","content":[...]}`. Rendering them as
/// text shows raw JSON to the audience, so they are parsed into nodes.
struct StoryBlock: Hashable, Sendable {
    let nodes: [Node]

    indirect enum Node: Hashable, Sendable {
        case heading(level: Int, text: String)
        case paragraph(text: String)
        case bulletList(items: [String])
        case orderedList(items: [String])
        case blockquote(text: String)
        case codeBlock(text: String)
        case image(src: String, alt: String?)
        case horizontalRule
        /// A node type this app does not know how to draw. Kept so the UI can
        /// show a labelled placeholder instead of silently dropping content.
        case unsupported(type: String)
    }

    init?(json: Any?) {
        guard let root = StoryBlock.asDictionary(json) else { return nil }
        let content = root["content"] as? [[String: Any]] ?? []
        let parsed = content.compactMap(StoryBlock.parse(node:))
        guard !parsed.isEmpty else { return nil }
        self.nodes = parsed
    }

    /// The body arrives either as a JSON object or as a JSON string,
    /// depending on whether `render` was requested. Handle both.
    private static func asDictionary(_ value: Any?) -> [String: Any]? {
        if let dict = value as? [String: Any] { return dict }
        if let string = value as? String, let data = string.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        }
        return nil
    }

    private static func parse(node: [String: Any]) -> Node? {
        let type = node["type"] as? String ?? "unknown"
        let attrs = node["attrs"] as? [String: Any] ?? [:]

        switch type {
        case "heading":
            let level = attrs["level"] as? Int ?? 2
            return .heading(level: level, text: text(in: node))
        case "paragraph":
            let t = text(in: node)
            return t.isEmpty ? nil : .paragraph(text: t)
        case "bulletList":
            return .bulletList(items: listItems(in: node))
        case "orderedList":
            return .orderedList(items: listItems(in: node))
        case "blockquote":
            return .blockquote(text: text(in: node))
        case "codeBlock":
            return .codeBlock(text: text(in: node))
        case "horizontalRule":
            return .horizontalRule
        case "dotImage", "image":
            guard let src = imageSource(attrs) else { return nil }
            return .image(src: src, alt: attrs["alt"] as? String)
        default:
            return .unsupported(type: type)
        }
    }

    private static func imageSource(_ attrs: [String: Any]) -> String? {
        if let data = attrs["data"] as? [String: Any] {
            if let identifier = data["identifier"] as? String {
                return "/dA/\(identifier)/asset"
            }
            if let asset = data["asset"] as? String { return asset }
        }
        return attrs["src"] as? String
    }

    private static func listItems(in node: [String: Any]) -> [String] {
        (node["content"] as? [[String: Any]] ?? []).map { text(in: $0) }
            .filter { !$0.isEmpty }
    }

    /// Recursively collects text, so nested marks (bold, links) survive as
    /// plain text rather than disappearing.
    private static func text(in node: [String: Any]) -> String {
        if let t = node["text"] as? String { return t }
        let children = node["content"] as? [[String: Any]] ?? []
        return children.map(text(in:)).joined()
    }
}

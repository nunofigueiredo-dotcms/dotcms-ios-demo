import Foundation

/// A dotCMS page asset, normalised for rendering.
///
/// The Page API returns rows -> columns -> containers -> contentlets. That
/// structure is preserved here so the SwiftUI mapping mirrors the Next.js
/// example one-to-one.
struct PageLayout: Sendable {
    let title: String?
    let rows: [Row]

    struct Row: Identifiable, Sendable {
        let id: Int
        let columns: [Column]
    }

    struct Column: Identifiable, Sendable {
        let id: String
        /// dotCMS uses a 12-unit grid.
        let width: Int
        let contentlets: [Contentlet]
    }

    var isEmpty: Bool {
        rows.allSatisfy { row in
            row.columns.allSatisfy { $0.contentlets.isEmpty }
        }
    }
}

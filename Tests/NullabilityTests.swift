import Foundation

// Simulates a content type whose fields were deleted by an author: every
// optional field nil. The app must degrade, never crash.
let stripped = Contentlet(
    contentType: "Blog",
    identifier: nil, inode: nil, title: nil, urlTitle: nil,
    summary: nil, publishDate: nil, link: nil, buttonText: nil,
    authorName: nil, imagePath: nil, imageWidth: nil, imageHeight: nil,
    body: nil, extra: [:]
)

print("=== All fields deleted ===")
print("  displayTitle:      '\(stripped.displayTitle)'  (must not be empty)")
print("  id:                '\(stripped.id)'  (must be stable, non-empty)")
print("  id stable?         \(stripped.id == stripped.id ? "yes" : "NO - breaks ForEach")")
print("  imageAspectRatio:  \(String(describing: stripped.imageAspectRatio))  (nil, no divide-by-zero)")

print("=== Degenerate image dimensions ===")
for (w, h) in [(0, 0), (100, 0), (0, 100), (-5, 10)] {
    let c = Contentlet(
        contentType: "Blog", identifier: "x", inode: nil, title: "t", urlTitle: nil,
        summary: nil, publishDate: nil, link: nil, buttonText: nil, authorName: nil,
        imagePath: nil, imageWidth: w, imageHeight: h, body: nil, extra: [:]
    )
    print("  \(w)x\(h) -> aspect \(String(describing: c.imageAspectRatio))")
}

print("=== Title that is whitespace only ===")
let blank = Contentlet(
    contentType: "Blog", identifier: "y", inode: nil, title: "   ", urlTitle: nil,
    summary: nil, publishDate: nil, link: nil, buttonText: nil, authorName: nil,
    imagePath: nil, imageWidth: nil, imageHeight: nil, body: nil, extra: [:]
)
print("  '   ' -> '\(blank.displayTitle)'")

guard stripped.id == stripped.id, !stripped.displayTitle.isEmpty, !stripped.id.isEmpty,
      stripped.imageAspectRatio == nil, blank.displayTitle == "Untitled" else {
    print("FAILED"); exit(1)
}
print("\nAll nullability tests passed — a stripped contentlet degrades safely.")

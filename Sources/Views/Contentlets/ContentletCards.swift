import SwiftUI

/// Full-bleed hero. `Banner.image` is required in the content type, but is
/// still treated as optional here per the nullability rule.
struct BannerCard: View {
    private let contentlet: Contentlet

    init(_ contentlet: Contentlet) {
        self.contentlet = contentlet
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            DotImage(
                identifier: contentlet.identifier,
                fallbackPath: contentlet.imagePath,
                aspectRatio: 4 / 3
            )

            LinearGradient(
                colors: [.black.opacity(0.75), .black.opacity(0.15), .clear],
                startPoint: .bottom, endPoint: .top
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(contentlet.displayTitle)
                    .font(.title.bold())
                    .foregroundStyle(.white)

                if let caption = contentlet.summary, !caption.isEmpty {
                    Text(caption)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(3)
                }

                if let buttonText = contentlet.buttonText, !buttonText.isEmpty {
                    Text(buttonText)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(.white, in: Capsule())
                        .foregroundStyle(.black)
                        .padding(.top, 2)
                }
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

/// Blog teaser as it appears inside a page container.
struct BlogCard: View {
    private let contentlet: Contentlet

    init(_ contentlet: Contentlet) {
        self.contentlet = contentlet
    }

    var body: some View {
        NavigationLink(value: contentlet) {
            VStack(alignment: .leading, spacing: 8) {
                DotImage(
                    identifier: contentlet.identifier,
                    fallbackPath: contentlet.imagePath
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(contentlet.displayTitle)
                    .font(.headline)
                    .multilineTextAlignment(.leading)

                if let summary = contentlet.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

/// Rich text (`webPageContent`). The body is StoryBlock JSON, not html.
struct RichTextBlock: View {
    private let contentlet: Contentlet

    init(_ contentlet: Contentlet) {
        self.contentlet = contentlet
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let body = contentlet.body {
                StoryBlockView(storyBlock: body)
            } else if let title = contentlet.title, !title.isEmpty {
                // Degrade to the title rather than rendering nothing.
                Text(title).font(.title3.bold())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CallToActionCard: View {
    private let contentlet: Contentlet

    init(_ contentlet: Contentlet) {
        self.contentlet = contentlet
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(contentlet.displayTitle)
                .font(.title3.bold())

            if let summary = contentlet.summary, !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let buttonText = contentlet.buttonText, !buttonText.isEmpty {
                Text(buttonText)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Color.accentColor, in: Capsule())
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
    }
}

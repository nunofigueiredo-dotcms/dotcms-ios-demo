import SwiftUI

/// Renders dotCMS StoryBlock content.
///
/// The body is ProseMirror-style JSON, not html, so each node type maps to a
/// SwiftUI view. Unknown node types render a labelled placeholder rather than
/// vanishing, which keeps the failure visible instead of silent.
struct StoryBlockView: View {
    let storyBlock: StoryBlock

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(storyBlock.nodes.enumerated()), id: \.offset) { _, node in
                view(for: node)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func view(for node: StoryBlock.Node) -> some View {
        switch node {
        case .heading(let level, let text):
            Text(text)
                .font(headingFont(level))
                .padding(.top, 6)

        case .paragraph(let text):
            Text(text)
                .font(.body)

        case .bulletList(let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•")
                        Text(item)
                    }
                }
            }

        case .orderedList(let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(index + 1).").monospacedDigit()
                        Text(item)
                    }
                }
            }

        case .blockquote(let text):
            HStack(spacing: 12) {
                Rectangle().fill(.tertiary).frame(width: 3)
                Text(text).italic().foregroundStyle(.secondary)
            }

        case .codeBlock(let text):
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text).font(.system(.footnote, design: .monospaced))
            }
            .padding(10)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

        case .image(let src, let alt):
            VStack(alignment: .leading, spacing: 4) {
                DotImage(identifier: nil, fallbackPath: src)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                if let alt, !alt.isEmpty {
                    Text(alt).font(.caption).foregroundStyle(.tertiary)
                }
            }

        case .horizontalRule:
            Divider()

        case .unsupported(let type):
            // Deliberately visible: the same philosophy as the unknown
            // content-type placeholder on the Home screen.
            Label("Unsupported block: \(type)", systemImage: "questionmark.square.dashed")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
        }
    }

    private func headingFont(_ level: Int) -> Font {
        switch level {
        case 1: .title.bold()
        case 2: .title2.bold()
        case 3: .title3.bold()
        default: .headline
        }
    }
}

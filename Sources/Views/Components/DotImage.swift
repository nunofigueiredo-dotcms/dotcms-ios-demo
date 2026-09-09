import SwiftUI

/// Loads a dotCMS asset resized for its display size.
///
/// Always routes through `DotCMSImageURL` so the request carries width and
/// quality parameters: the raw demo assets are up to 5184px / 2.2 MB, versus
/// ~18 KB resized. Never point AsyncImage at an unresized dotCMS asset.
struct DotImage: View {
    let identifier: String?
    var fieldName: String = "image"
    var fallbackPath: String?
    var aspectRatio: CGFloat? = 16 / 9
    var contentMode: ContentMode = .fill

    var body: some View {
        GeometryReader { geo in
            let url = DotCMSImageURL.url(
                identifier: identifier,
                fieldName: fieldName,
                fallbackPath: fallbackPath,
                width: geo.size.width
            )
            AsyncImage(url: url, transaction: .init(animation: .easeIn(duration: 0.2))) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: contentMode)
                case .failure:
                    placeholder(icon: "photo.badge.exclamationmark")
                case .empty:
                    placeholder(icon: nil)
                @unknown default:
                    placeholder(icon: nil)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }

    /// A missing image degrades to a neutral tile, never a blank gap.
    private func placeholder(icon: String?) -> some View {
        ZStack {
            Rectangle().fill(.quaternary)
            if let icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

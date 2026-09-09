import SwiftUI

/// The single fallback used for every empty collection and failed fetch.
/// Consistency matters here: the audience should read these as designed
/// states, not as the app falling over.
struct EmptyStateView: View {
    let title: String
    var message: String? = nil
    var systemImage: String = "tray"

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let message { Text(message) }
        }
    }
}

struct ErrorStateView: View {
    let error: DotCMSError
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Couldn't load content", systemImage: "exclamationmark.triangle")
        } description: {
            VStack(spacing: 8) {
                Text(error.errorDescription ?? "Unknown error")
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        } actions: {
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}

/// Skeleton placeholder shown while content loads, sized like the real row so
/// the layout does not jump when data arrives.
struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
                .aspectRatio(16 / 9, contentMode: .fit)
            RoundedRectangle(cornerRadius: 4).fill(.quaternary).frame(height: 18)
            RoundedRectangle(cornerRadius: 4).fill(.quaternary)
                .frame(height: 14).frame(maxWidth: 220)
        }
        .redacted(reason: .placeholder)
        .shimmer()
    }
}

private struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.35), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 1.5)
                    .offset(x: phase * geo.size.width * 1.5)
                    .blendMode(.plusLighter)
                }
                .allowsHitTesting(false)
            }
            .clipped()
            .task {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    func shimmer() -> some View { modifier(Shimmer()) }
}

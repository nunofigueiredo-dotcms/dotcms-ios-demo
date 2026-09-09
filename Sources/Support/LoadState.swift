import Foundation

/// Every screen moves through exactly these states, so loading, empty and
/// error handling is designed once rather than improvised per screen.
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case failed(DotCMSError)

    var value: Value? {
        if case .loaded(let v) = self { return v }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

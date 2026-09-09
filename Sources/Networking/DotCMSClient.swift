import Apollo
import ApolloAPI
import Foundation

/// Injects the dotCMS auth token and the server-side cache-control headers
/// into every GraphQL request.
///
/// `dotcachettl` is the demo-critical one: see `CachePolicy`.
final class DotCMSInterceptor: ApolloInterceptor {
    let id = "DotCMSInterceptor"

    /// Read on each request so the Settings toggle takes effect immediately.
    private let policyProvider: @Sendable () -> CachePolicy

    init(policyProvider: @escaping @Sendable () -> CachePolicy) {
        self.policyProvider = policyProvider
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        if let token = try? TokenStore.token() {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
        }
        let policy = policyProvider()
        request.addHeader(name: "dotcachettl", value: String(policy.ttlSeconds))
        chain.proceedAsync(
            request: request, response: response, interceptor: self, completion: completion
        )
    }
}

/// Builds the interceptor chain, adding ours ahead of the network fetch.
private final class DotCMSInterceptorProvider: DefaultInterceptorProvider {
    private let policyProvider: @Sendable () -> CachePolicy

    init(store: ApolloStore, client: URLSessionClient,
         policyProvider: @escaping @Sendable () -> CachePolicy) {
        self.policyProvider = policyProvider
        super.init(client: client, store: store)
    }

    override func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> [any ApolloInterceptor] {
        var chain = super.interceptors(for: operation)
        chain.insert(DotCMSInterceptor(policyProvider: policyProvider), at: 0)
        return chain
    }
}

/// The app's single GraphQL entry point.
@MainActor
final class DotCMSClient {
    static let shared = DotCMSClient()

    /// Switched at runtime from the Settings screen.
    nonisolated(unsafe) static var cachePolicy: CachePolicy = .demo

    private let apollo: ApolloClient
    private let config: AppConfig

    init(config: AppConfig = .shared) {
        self.config = config
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let provider = DotCMSInterceptorProvider(
            store: store,
            client: URLSessionClient(),
            policyProvider: { DotCMSClient.cachePolicy }
        )
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: config.graphQLURL
        )
        self.apollo = ApolloClient(networkTransport: transport, store: store)
    }

    /// Runs a query, always bypassing Apollo's local cache so the dotCMS
    /// server-side TTL is the single source of caching truth. Two competing
    /// caches would make the demo's refresh behaviour unpredictable.
    func fetch<Query: GraphQLQuery>(_ query: Query) async throws -> Query.Data {
        guard TokenStore.isConfigured else {
            throw DotCMSError.notConfigured("no API token")
        }
        return try await withCheckedThrowingContinuation { continuation in
            apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely) { result in
                switch result {
                case .success(let response):
                    if let errors = response.errors, !errors.isEmpty {
                        continuation.resume(
                            throwing: DotCMSError.graphQL(errors.map { $0.message ?? "GraphQL error" })
                        )
                        return
                    }
                    guard let data = response.data else {
                        continuation.resume(throwing: DotCMSError.decoding("empty response"))
                        return
                    }
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: Self.map(error))
                }
            }
        }
    }

    private static func map(_ error: any Error) -> DotCMSError {
        if let response = error as? ResponseCodeInterceptor.ResponseCodeError,
           case .invalidResponseCode(let http, _) = response,
           http?.statusCode == 401 {
            return .unauthorized
        }
        return .network(error.localizedDescription)
    }

    /// Lucene filter restricting results to the configured site.
    /// Without this, content duplicated across sites appears twice.
    var siteFilter: String {
        config.siteID.isEmpty ? "" : "+conHost:\(config.siteID)"
    }
}

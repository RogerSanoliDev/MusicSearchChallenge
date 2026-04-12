//
//  APIClient.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Foundation

public protocol APIClientProtocol: Sendable {
    func performRequest<T:Decodable>(endpoint: Endpoint, session: URLSessionProtocol) async throws -> T
}

public extension APIClientProtocol {
    func performRequest<T:Decodable>(endpoint: Endpoint) async throws -> T {
        try await performRequest(endpoint: endpoint, session: URLSession.shared)
    }
}

public final class APIClient: APIClientProtocol {
    public static let shared = APIClient()
    
    private let requestDeduplicator: any RequestDeduplicating
    private let retryStrategy: RequestRetryStrategy
    private let sleep: @Sendable (Double) async throws -> Void
    
    public init() {
        self.requestDeduplicator = InFlightRequestDeduplicator()
        self.retryStrategy = RequestRetryStrategy()
        self.sleep = { seconds in
            try await Task.sleep(for: .seconds(seconds))
        }
    }
    
    init(
        requestDeduplicator: any RequestDeduplicating,
        retryStrategy: RequestRetryStrategy = RequestRetryStrategy(),
        sleep: @escaping @Sendable (Double) async throws -> Void = { seconds in
            try await Task.sleep(for: .seconds(seconds))
        }
    ) {
        self.requestDeduplicator = requestDeduplicator
        self.retryStrategy = retryStrategy
        self.sleep = sleep
    }
    
    public func performRequest<T:Decodable>(endpoint: Endpoint, session: URLSessionProtocol) async throws -> T {
        guard let url = endpoint.url else { throw NetworkError.badURLFormat }
        
        let (data, response) = try await data(for: url, session: session)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidHTTPResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidStatusCode(errorCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodeError(error: error)
        }
    }

    private func data(for url: URL, session: URLSessionProtocol) async throws -> (Data, URLResponse) {
        var attempt = 0

        while true {
            do {
                return try await requestDeduplicator.data(for: url, session: session)
            } catch {
                guard retryStrategy.shouldRetry(after: error),
                      attempt < retryStrategy.maxRetryCount else {
                    throw error
                }

                attempt += 1
                try await sleep(retryStrategy.delayInSeconds(forRetryAttempt: attempt))
            }
        }
    }
}

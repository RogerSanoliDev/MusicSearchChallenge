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
    private init() {}
    
    public func performRequest<T:Decodable>(endpoint: Endpoint, session: URLSessionProtocol) async throws -> T {
        guard let url = endpoint.url else { throw NetworkError.badURLFormat }
        
        let (data, response) = try await session.data(from: url)
        
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
}

//
//  APIClientMock.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Foundation
@testable import Network

actor APIClientMock: APIClientProtocol {
    var performRequestCount = 0
    var receivedEndpoint: Endpoint?
    var result: Result<Any, Error>?

    func setResult(_ result: Result<Any, Error>) {
        self.result = result
    }
    
    func performRequest<T>(
        endpoint: Endpoint,
        session: URLSessionProtocol
    ) async throws -> T where T : Decodable {
        
        performRequestCount += 1
        receivedEndpoint = endpoint
        
        guard let result = result else {
            fatalError("Result not set on APIClientMock")
        }
        
        switch result {
        case .success(let value):
            return value as! T
        case .failure(let error):
            throw error
        }
    }
}

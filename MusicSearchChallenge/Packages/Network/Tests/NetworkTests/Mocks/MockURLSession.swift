//
//  MockURLSession.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Network
import Foundation

struct MockURLSession: URLSessionProtocol {
    
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error {
            throw error
        }
        
        guard let data, let response else {
            fatalError("MockURLSession not properly configured")
        }
        
        return (data, response)
    }
}

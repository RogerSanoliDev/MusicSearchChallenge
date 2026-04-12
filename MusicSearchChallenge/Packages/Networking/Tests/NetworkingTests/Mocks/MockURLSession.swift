//
//  MockURLSession.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Networking
import Foundation

struct MockURLSession: URLSessionProtocol {
    
    var data: Data?
    var response: URLResponse?
    var error: Error?
    var delayNanoseconds: UInt64 = 0
    var callCounter: MockURLSessionCallCounter?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        await callCounter?.increment()
        
        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        
        if let error {
            throw error
        }
        
        guard let data, let response else {
            fatalError("MockURLSession not properly configured")
        }
        
        return (data, response)
    }
}

//
//  MockURLSession+stub.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Foundation

extension MockURLSession {
    static func stub(data: Data? = MockResponse.stub().toData(),
                     response: URLResponse? = .stub(),
                     error: Error? = nil,
                     delayNanoseconds: UInt64 = 0,
                     callCounter: MockURLSessionCallCounter? = nil) -> MockURLSession {
        
        return MockURLSession(data: data,
                              response: response,
                              error: error,
                              delayNanoseconds: delayNanoseconds,
                              callCounter: callCounter)
    }
}

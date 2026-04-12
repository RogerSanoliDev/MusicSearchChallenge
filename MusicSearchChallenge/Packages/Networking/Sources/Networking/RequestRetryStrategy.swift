//
//  RequestRetryStrategy.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 12/04/26.
//

import Foundation

public struct RequestRetryStrategy: Sendable {
    public let maxRetryCount: Int

    public init(maxRetryCount: Int = 5) {
        self.maxRetryCount = maxRetryCount
    }

    func shouldRetry(after error: Error) -> Bool {
        guard let networkError = error as? NetworkError else {
            return true
        }

        switch networkError {
        case .invalidStatusCode(let errorCode):
            return (500...599).contains(errorCode)
        case .badURLFormat, .invalidHTTPResponse, .decodeError:
            return false
        }
    }

    func delayInSeconds(forRetryAttempt attempt: Int) -> Double {
        Double(attempt)
    }
}

//
//  Untitled.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

public enum NetworkError: Error, Equatable {
    case badURLFormat
    case invalidHTTPResponse
    case invalidStatusCode(errorCode: Int)
    case decodeError(error: Error)
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.badURLFormat, .badURLFormat):
            return true
            
        case (.invalidHTTPResponse, .invalidHTTPResponse):
            return true
            
        case let (.invalidStatusCode(lhsCode), .invalidStatusCode(rhsCode)):
            return lhsCode == rhsCode
            
        case let (.decodeError(lhsError), .decodeError(rhsError)):
            return type(of: lhsError) == type(of: rhsError)
            
        default:
            return false
        }
    }
}

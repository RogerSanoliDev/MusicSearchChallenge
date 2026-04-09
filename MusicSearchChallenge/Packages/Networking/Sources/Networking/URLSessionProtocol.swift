//
//  URLSessionProtocol.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Foundation

public protocol URLSessionProtocol: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

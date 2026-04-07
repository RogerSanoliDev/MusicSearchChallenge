//
//  Endpoint.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Foundation

public struct Endpoint {
    private(set) var url: URL?
    
    public init(
        baseURL: String = BaseURL.baseURL,
        path: String,
        queryItems: [String: String]? = nil
    ) {
        guard var components = URLComponents(string: baseURL),
              let host = components.host,
              !host.isEmpty else {
            self.url = nil
            return
        }
    
        let normalizedPath = path.hasPrefix("/") ? path : "/" + path
        components.path = normalizedPath
        
        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
                // sorted for determinism
                .sorted { $0.key < $1.key }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        self.url = components.url
    }
}

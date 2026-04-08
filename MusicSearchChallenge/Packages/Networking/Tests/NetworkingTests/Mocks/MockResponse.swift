//
//  MockResponse.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//
import Foundation

struct MockResponse: Codable, Equatable {
    let id: Int
    let name: String
    
    func toData() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}

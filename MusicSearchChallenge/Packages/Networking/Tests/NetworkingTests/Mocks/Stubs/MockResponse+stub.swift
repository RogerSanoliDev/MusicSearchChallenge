//
//  MockResponse+stub.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Foundation

extension MockResponse {
    static func stub(id: Int = 1,
                     name: String = "Name") -> MockResponse {
        return MockResponse(id: id,
                            name: name)
    }
}

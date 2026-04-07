//
//  URLResponse+stub.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Foundation

extension URLResponse {
    static func stub(url: URL? = URL(string: "https://test.com"),
                     statusCode: Int = 200,
                     httpVersion: String? = nil,
                     headerFields: [String : String]? = nil) -> URLResponse? {
        guard let url else { return nil }
        
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: headerFields
        )
    }
}

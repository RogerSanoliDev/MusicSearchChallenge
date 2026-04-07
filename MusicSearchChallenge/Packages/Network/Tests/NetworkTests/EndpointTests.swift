//
//  EndpointTests.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Testing
@testable import Network

struct EndpointTests {
    
    @Test
    func init_whenValidPathAndQueryItems_buildsCorrectURL() {
        let endpoint = Endpoint(
            path: "/search",
            queryItems: [
                "term": "beatles",
                "limit": "10"
            ]
        )
        
        #expect(endpoint.url?.absoluteString == "https://itunes.apple.com/search?limit=10&term=beatles")
    }
    
    @Test
    func init_whenEmptyBaseURL_resultsNil() {
        let endpoint = Endpoint(
            baseURL: "",
            path: "/search",
            queryItems: nil
        )
        
        let urlString = endpoint.url?.absoluteString
        #expect(urlString == nil)
    }
    
    @Test
    func init_whenEmptyPath_resultsBaseURL() {
        let endpoint = Endpoint(
            path: "",
            queryItems: nil
        )
        
        let urlString = endpoint.url?.absoluteString
        #expect(urlString == "https://itunes.apple.com/")
    }
    
    @Test
    func init_whenEmptyQueryItems_doesNotAppendQuery() {
        let endpoint = Endpoint(
            path: "/search",
            queryItems: [:]
        )
        
        #expect(endpoint.url != nil)
        
        let urlString = endpoint.url?.absoluteString
        #expect(urlString?.contains("?") == false)
    }
    
    @Test
    func init_whenNilQueryItems_doesNotAppendQuery() {
        let endpoint = Endpoint(
            path: "/search",
            queryItems: nil
        )
        
        #expect(endpoint.url != nil)
        
        let urlString = endpoint.url?.absoluteString
        #expect(urlString?.contains("?") == false)
    }
    
    @Test
    func init_whenQueryItemsHaveSpecialCharacters_buildsCorrectURL() {
        let endpoint = Endpoint(
            path: "/search",
            queryItems: [
                "term": "taylor swift",
                "media": "music"
            ]
        )
        
        let urlString = endpoint.url?.absoluteString
        #expect(urlString?.contains("taylor%20swift") == true)
    }
    
    @Test
    func init_whenQueryItemsHaveSlashes_buildsCorrectURL() {
        let endpoint = Endpoint(
            path: "/search",
            queryItems: [
                "term": "AC/DC"
            ]
        )
        
        let urlString = endpoint.url?.absoluteString
        #expect(urlString?.contains("AC/DC") == true)
    }
    
    @Test
    func init_whenSameInput_producesSameURL() {
        let endpoint1 = Endpoint(
            path: "/search",
            queryItems: ["term": "rock"]
        )
        
        let endpoint2 = Endpoint(
            path: "/search",
            queryItems: ["term": "rock"]
        )
        
        #expect(endpoint1.url == endpoint2.url)
    }
}

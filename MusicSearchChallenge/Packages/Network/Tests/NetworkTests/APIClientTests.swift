//
//  APIClientTests.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Testing
import Foundation

@testable import Network

struct APIClientTests {
    private let sut = APIClient.shared
    private let endpoint = Endpoint(path: "/search")

    @Test
    func performRequest_whenSuccessful_decodesResponse() async {
        let mockSession: MockURLSession = .stub(
            data: MockResponse.stub(id: 2).toData()
        )
        
        var result: MockResponse?
        do {
            result = try await sut.performRequest(
                endpoint: endpoint,
                session: mockSession
            )
        } catch {
            Issue.record("Test Failed: \(error)")
        }
            
        #expect(result == MockResponse(id: 2, name: "Name"))
    }
    
    @Test
    func performRequest_whenInvalidURL_throwsError() async {
        let mockSession: MockURLSession = .stub()
        let invalidEndpoint = Endpoint(baseURL: "", path: "")
        
        await #expect(throws: NetworkError.badURLFormat) {
            let _: MockResponse = try await sut.performRequest(
                endpoint: invalidEndpoint,
                session: mockSession
            )
        }
    }
    
    @Test
    func performRequest_whenInvalidHTTPResponse_throwsError() async {
        let mockSession: MockURLSession = .stub(response: URLResponse())
        
        await #expect(throws: NetworkError.invalidHTTPResponse) {
            let _: MockResponse = try await sut.performRequest(
                endpoint: endpoint,
                session: mockSession
            )
        }
    }

    @Test
    func performRequest_whenInvalidStatusCode_throwsError() async {
        let invalidResponse: URLResponse? = .stub(statusCode: 404)
        let mockSession: MockURLSession = .stub(response: invalidResponse)
        
        await #expect(throws: NetworkError.invalidStatusCode(errorCode: 404)) {
            let _: MockResponse = try await sut.performRequest(
                endpoint: endpoint,
                session: mockSession
            )
        }
    }

    @Test
    func performRequest_whenDecodingError_throwsError() async {
        let invalidJSON = """
        {
            "invalid_key": "oops"
        }
        """.data(using: .utf8)
        
        let mockSession: MockURLSession = .stub(data: invalidJSON)
        
        await #expect {
            let _: MockResponse = try await sut.performRequest(
                endpoint: endpoint,
                session: mockSession
            )
        } throws: { error in
            guard case NetworkError.decodeError = error else {
                return false
            }
            return true
        }
    }
//    
//    // MARK: - Session Error
//    
//    @Test
//    func performRequest_sessionThrows_propagatesError() async {
//        enum TestError: Error { case failed }
//        
//        let mockSession = MockURLSession()
//        mockSession.error = TestError.failed
//        
//        let endpoint = MockEndpoint(url: URL(string: "https://test.com"))
//        
//        await #expect(throws: TestError.failed) {
//            let _: MockResponse = try await apiClient.performRequest(
//                endpoint: endpoint,
//                session: mockSession
//            )
//        }
//    }
}

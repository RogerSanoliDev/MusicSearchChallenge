//
//  APIClientTests.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 07/04/26.
//

import Testing
import Foundation

@testable import Networking

struct APIClientTests {
    private let endpoint = Endpoint(path: "/search")

    @Test
    func performRequest_whenSuccessful_decodesResponse() async {
        let sut = APIClient(requestDeduplicator: InFlightRequestDeduplicator())
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
        let sut = APIClient(requestDeduplicator: InFlightRequestDeduplicator())
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
        let sut = APIClient(requestDeduplicator: InFlightRequestDeduplicator())
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
        let sut = APIClient(requestDeduplicator: InFlightRequestDeduplicator())
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
        let sut = APIClient(requestDeduplicator: InFlightRequestDeduplicator())
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

    @Test
    func performRequest_whenSameRequestIsInFlight_reusesExistingTask() async throws {
        let sut = APIClient(requestDeduplicator: InFlightRequestDeduplicator())
        let callCounter = MockURLSessionCallCounter()
        let mockSession: MockURLSession = .stub(
            delayNanoseconds: 100_000_000,
            callCounter: callCounter
        )

        async let firstRequest: MockResponse = sut.performRequest(
            endpoint: endpoint,
            session: mockSession
        )
        async let secondRequest: MockResponse = sut.performRequest(
            endpoint: endpoint,
            session: mockSession
        )

        let (firstResponse, secondResponse) = try await (firstRequest, secondRequest)

        #expect(firstResponse == MockResponse.stub())
        #expect(secondResponse == MockResponse.stub())
        #expect(await callCounter.count == 1)
    }

    @Test
    func performRequest_whenRequestsDiffer_executesEachRequestIndependently() async throws {
        let sut = APIClient(requestDeduplicator: InFlightRequestDeduplicator())
        let callCounter = MockURLSessionCallCounter()
        let mockSession: MockURLSession = .stub(callCounter: callCounter)
        let firstEndpoint = Endpoint(path: "/search", queryItems: ["term": "beatles"])
        let secondEndpoint = Endpoint(path: "/search", queryItems: ["term": "queen"])

        let _: MockResponse = try await sut.performRequest(
            endpoint: firstEndpoint,
            session: mockSession
        )
        let _: MockResponse = try await sut.performRequest(
            endpoint: secondEndpoint,
            session: mockSession
        )

        #expect(await callCounter.count == 2)
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

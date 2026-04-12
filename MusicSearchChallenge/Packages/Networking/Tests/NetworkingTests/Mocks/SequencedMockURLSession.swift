//
//  SequencedMockURLSession.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 12/04/26.
//

import Networking
import Foundation

actor SequencedMockURLSession: URLSessionProtocol {
    typealias Response = Result<(Data, URLResponse), Error>

    private var responses: [Response]
    private(set) var callCount = 0

    init(responses: [Response]) {
        self.responses = responses
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        callCount += 1

        guard !responses.isEmpty else {
            fatalError("SequencedMockURLSession has no more queued responses")
        }

        return try responses.removeFirst().get()
    }
}

//
//  InFlightRequestDeduplicator.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 12/04/26.
//

import Foundation

protocol RequestDeduplicating: Sendable {
    func data(for url: URL, session: URLSessionProtocol) async throws -> (Data, URLResponse)
}

actor InFlightRequestDeduplicator: RequestDeduplicating {
    typealias Response = (Data, URLResponse)

    private var tasksByURL: [URL: Task<Response, Error>] = [:]

    func data(for url: URL, session: URLSessionProtocol) async throws -> Response {
        if let existingTask = tasksByURL[url] {
            return try await existingTask.value
        }

        let task = Task<Response, Error> {
            defer {
                Task {
                    self.removeTask(for: url)
                }
            }

            return try await session.data(from: url)
        }

        tasksByURL[url] = task
        return try await task.value
    }

    private func removeTask(for url: URL) {
        tasksByURL[url] = nil
    }
}

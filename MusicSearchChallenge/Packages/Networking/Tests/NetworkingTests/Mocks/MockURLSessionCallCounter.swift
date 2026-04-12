//
//  MockURLSessionCallCounter.swift
//  Network
//
//  Created by Roger dos Santos Oliveira on 12/04/26.
//

actor MockURLSessionCallCounter {
    private(set) var count = 0

    func increment() {
        count += 1
    }
}

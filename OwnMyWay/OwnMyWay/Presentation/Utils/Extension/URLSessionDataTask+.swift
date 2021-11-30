//
//  URLSessionDataTask+.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/25.
//

import Foundation

protocol Cancellable {
    func resumeFetch()
    func cancelFetch()
}

extension URLSessionDataTask: Cancellable {
    func resumeFetch() {
        self.resume()
    }

    func cancelFetch() {
        self.cancel()
    }
}

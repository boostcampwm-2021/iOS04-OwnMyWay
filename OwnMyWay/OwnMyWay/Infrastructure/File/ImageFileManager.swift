//
//  ImageFileManager.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/16.
//

import Foundation

final class ImageFileManager {
    private let fileManager: FileManager
    private let appDirectory: String
    private let cache: URLCache

    static let shared = ImageFileManager(fileManager: FileManager.default)

    private init(fileManager: FileManager) {
        self.fileManager = fileManager
        self.appDirectory = "OwnMyWay"
        let cachesURL = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("DownloadCache")
        cache = .init(memoryCapacity: 0, diskCapacity: 100_000_000, directory: diskCacheURL)
        do {
            try self.configureAppURL()
        } catch let error {
            print(error)
        }
    }

    func imageInDocuemtDirectory(image: String) -> URL? {
        return self.appURL()?.appendingPathComponent(image)
    }

    func copyPhoto(from source: URL, completion: (Result<String, Error>) -> Void) {
        guard let destinationURL = self.appURL()?
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(source.pathExtension)
        else { return }
        do {
            if !self.photoExists(at: destinationURL) {
                try self.fileManager.copyItem(at: source, to: destinationURL)
            }
        } catch let error {
            completion(.failure(error))
        }
        completion(.success(destinationURL.lastPathComponent))
    }

    func removePhoto(of photoID: String, completion: (Result<Void, Error>) -> Void) {
        guard let url = self.imageInDocuemtDirectory(image: photoID) else {
            completion(.failure(NSError.init()))
            return
        }
        do {
            if self.photoExists(at: url) {
                try self.fileManager.removeItem(at: url)
            }
        } catch let error {
            completion(.failure(error))
        }
        completion(.success(()))
    }

    private func configureAppURL() throws {
        guard let appURL = self.appURL(),
              !self.fileManager.fileExists(atPath: appURL.absoluteString)
        else { return }
        try self.fileManager.createDirectory(at: appURL, withIntermediateDirectories: true)
    }

    private func photoExists(at url: URL) -> Bool {
        return self.fileManager.fileExists(atPath: url.path)
    }

    private func documentURL() -> URL? {
        return self.fileManager.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first
    }

    private func appURL() -> URL? {
        return self.documentURL()?.appendingPathComponent(self.appDirectory)
    }

    func cachedData(request: URLRequest) -> Data? {
        return self.cache.cachedResponse(for: request)?.data
    }

    func saveToCache(request: URLRequest, response: URLResponse, data: Data) {
        self.cache.storeCachedResponse(
            CachedURLResponse(response: response, data: data), for: request
        )
    }
}

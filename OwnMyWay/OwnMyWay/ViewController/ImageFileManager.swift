//
//  ImageFileManager.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/16.
//

import Foundation

class ImageFileManager {
    private let fileManager: FileManager
    private let appDirectory: String

    static let shared = ImageFileManager(fileManager: FileManager.default)

    private init(fileManager: FileManager) {
        self.fileManager = fileManager
        self.appDirectory = "OwnMyWay"
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

    private func cacheURL() -> URL? {
        return self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    }

    func imageInCache(url: URL) -> URL? {
        guard var cacheURL = self.cacheURL() else { return nil }
        cacheURL.appendPathComponent(url.absoluteString.replacingOccurrences(of: "/", with: ""))
        if self.fileManager.fileExists(atPath: cacheURL.path) {
            print(cacheURL)
            return cacheURL
        } else {
            return nil
        }
    }

    func saveToCache(data: Data, url: URL) -> URL? {
        guard var cacheURL = self.cacheURL() else { return nil }
        cacheURL.appendPathComponent(url.absoluteString.replacingOccurrences(of: "/", with: ""))
        fileManager.createFile(atPath: cacheURL.path, contents: data)
        return cacheURL
    }
}

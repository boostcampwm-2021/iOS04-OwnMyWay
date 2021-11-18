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

    func copyPhoto(from source: URL, completion: (URL?, Error?) -> Void) {
        guard let destinationURL = self.appURL()?
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(source.pathExtension)
        else { return }
        do {
            if !self.photoExists(at: destinationURL) {
                try self.fileManager.copyItem(at: source, to: destinationURL)
            }
        } catch let error {
            completion(nil, error)
        }
        completion(destinationURL, nil)
    }

    func removePhoto(at url: URL, completion: (Bool, Error?) -> Void) {
        do {
            if self.photoExists(at: url) {
                try self.fileManager.removeItem(at: url)
            }
        } catch let error {
            completion(false, error)
        }
        completion(true, nil)
    }

    private func configureAppURL() throws {
        guard let appURL = self.appURL(),
              !self.fileManager.fileExists(atPath: appURL.absoluteString)
        else { return }
        try self.fileManager.createDirectory(at: appURL, withIntermediateDirectories: true)
    }

    private func photoExists(at url: URL) -> Bool {
        return self.fileManager.fileExists(atPath: url.absoluteString)
    }

    private func documentURL() -> URL? {
        return self.fileManager.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first
    }

    private func appURL() -> URL? {
        return self.documentURL()?.appendingPathComponent(self.appDirectory)
    }

}

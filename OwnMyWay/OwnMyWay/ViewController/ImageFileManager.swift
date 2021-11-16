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

    init(fileManager: FileManager) {
        self.fileManager = fileManager
        self.appDirectory = "OwnMyWay"
    }

    func copyPhoto(from source: URL, completion: (URL?, Error?) -> Void) {
        guard let destinationURL = self.destinationURL()
        else { return }
        do {
            if self.photoExists(at: destinationURL) {
                try self.fileManager.removeItem(at: destinationURL)
            }
            try self.fileManager.copyItem(at: source, to: destinationURL)
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

    private func photoExists(at url: URL) -> Bool {
        return self.fileManager.fileExists(atPath: url.absoluteString)
    }

    private func destinationURL() -> URL? {
        let documentURL = self.fileManager.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first
        return documentURL?.appendingPathComponent(self.appDirectory)
    }

}

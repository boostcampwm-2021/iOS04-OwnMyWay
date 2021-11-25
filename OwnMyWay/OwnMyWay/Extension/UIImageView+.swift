//
//  UIImageView+.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setLocalImage(with url: URL?) {
        self.image = UIImage(contentsOfFile: url?.path ?? "")
    }

    func setNetworkImage(with url: URL?) -> Cancellable? {
        guard let url = url else { return nil }
        if let cachedURL = ImageFileManager.shared.imageInCache(url: url) {
            self.image = UIImage(contentsOfFile: cachedURL.path)
            return nil
        }
        let downloadTask = URLSession.shared.downloadTask(with: url) { tmpURL, response, error in
            guard let tmpURL = tmpURL, let data = try? Data(contentsOf: tmpURL)
            else { return }
            guard let url = ImageFileManager.shared.saveToCache(data: data, url: url)
            else { return }
            DispatchQueue.main.async {
                self.image = UIImage(contentsOfFile: url.path)
            }
        }
        downloadTask.resumeFetch()
//        let downloadTask = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data else {
//                return
//            }
//            DispatchQueue.main.async {
//                self.image = UIImage(data: data)
//            }
//            ImageFileManager.shared.saveToCache(data: data, url: url)
//        }
//        downloadTask.resumeFetch()
        return downloadTask
    }

    func cancelFetch(downloadTask: Cancellable?) {
        downloadTask?.cancelFetch()
    }
}

protocol Cancellable {
    func resumeFetch()
    func cancelFetch()
}

extension URLSessionDownloadTask: Cancellable {
    func resumeFetch() {
        self.resume()
    }

    func cancelFetch() {
        self.cancel()
    }
}

//
//  UIImageView+.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import UIKit

extension UIImageView {
    func setLocalImage(with url: URL?) {
        self.image = UIImage(contentsOfFile: url?.path ?? "")
    }

    func setNetworkImage(with url: URL?) -> Cancellable? {
        guard let url = url else { return nil }
        let request = URLRequest(url: url)

        if let cachedData = ImageFileManager.shared.cachedData(request: request) {
            DispatchQueue.main.async {
                self.image = UIImage(data: cachedData)
            }
            return nil
        }

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else { return }
            guard let response = response,
                  let data = data
            else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
            ImageFileManager.shared.saveToCache(request: request, response: response, data: data)
        }
        dataTask.resumeFetch()
        return dataTask
    }

    func cancelFetch(downloadTask: Cancellable?) {
        downloadTask?.cancelFetch()
    }
}

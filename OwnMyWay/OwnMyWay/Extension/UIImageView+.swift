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

    func setNetworkImage(with url: URL?) {
        guard let url = url else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}

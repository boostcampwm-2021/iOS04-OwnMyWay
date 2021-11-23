//
//  UIImageView+.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(with url: URL?) {
        self.kf.setImage(with: url)
    }
}

extension UIImageView {
    func resize() {
        guard let image = self.image else { return }
        let ratio = image.size.width / image.size.height
        let newWidth = UIScreen.main.bounds.width
        let newHeight = newWidth / ratio
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: newWidth),
            heightAnchor.constraint(equalToConstant: newHeight)
        ])
    }
}

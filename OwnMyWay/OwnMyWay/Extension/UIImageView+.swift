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

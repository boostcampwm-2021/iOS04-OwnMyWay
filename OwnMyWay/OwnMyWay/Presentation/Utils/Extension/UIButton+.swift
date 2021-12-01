//
//  UIButton+.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/22.
//

import UIKit

extension UIButton {
    func configureTrackingButton() {
        self.layer.cornerRadius = 10
        let image = UIImage(systemName: "circle.fill")
        let normalImage = image?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        let selectedImage = image?.withTintColor(.red, renderingMode: .alwaysOriginal)
        self.setImage(normalImage, for: .normal)
        self.setImage(selectedImage, for: .selected)
        self.setTitleColor(.systemGray, for: .normal)
        self.setTitleColor(.red, for: .selected)
    }
}

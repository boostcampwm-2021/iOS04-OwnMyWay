//
//  PhotoCell.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/16.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    static let identifier = "PhotoCell"

    @IBOutlet weak var imageView: UIImageView!

    func configure(url: URL?) {
        self.layer.cornerRadius = 10
        self.imageView.setImage(with: url)
    }

    func configureAccessibility(index: Int) {
        self.isAccessibilityElement = true
        self.accessibilityValue = index == 0 ? "이미지 추가 버튼" : "\(index)번째 사진"
        self.accessibilityHint = index == 0 ? "눌러서 이미지를 추가하세요." : "눌러서 이미지를 제거할 수 있어요."
    }
}

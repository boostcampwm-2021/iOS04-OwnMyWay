//
//  LandmarkCardCell.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import UIKit
import Kingfisher

class LandmarkCardCell: UICollectionViewCell {
    static let identifier: String = "LandmarkCardCell"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(landmark: Landmark) {
        self.imageView.kf.setImage(with: landmark.image)
        self.titleLabel.text = landmark.title
    }
}

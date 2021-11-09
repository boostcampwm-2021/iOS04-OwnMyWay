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

    override func prepareForReuse() {
        self.imageView.image = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10.0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 10.0
    }

    func bind(with landmark: Landmark) {
        self.imageView.kf.setImage(with: landmark.image)
        self.titleLabel.text = landmark.title
    }
}

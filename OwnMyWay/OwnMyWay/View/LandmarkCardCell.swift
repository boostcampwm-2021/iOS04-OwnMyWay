//
//  LandmarkCardCell.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import UIKit

class LandmarkCardCell: UICollectionViewCell {
    static let identifier: String = "LandmarkCardCell"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(title: String?, image: URL?) {
        guard let image = image, let data = try? Data(contentsOf: image) else {
            return
        }
        self.imageView.image = UIImage(data: data)
        self.titleLabel.text = title
    }
}

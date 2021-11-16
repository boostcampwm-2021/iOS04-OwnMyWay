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

    func configure(url: URL) {
        self.imageView.setImage(with: url)
    }

}

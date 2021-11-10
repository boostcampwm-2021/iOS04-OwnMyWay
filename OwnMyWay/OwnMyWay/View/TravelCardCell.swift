//
//  TravelCardCell.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import UIKit

class TravelCardCell: UICollectionViewCell {
    static let identifier = "TravelCardCell"

    @IBOutlet private weak var travelTitleLabel: UILabel!
    @IBOutlet private weak var travelDateLabel: UILabel!
    @IBOutlet weak var travelCardImageView: UIImageView!

    func configure(with travel: Travel) {
        self.travelTitleLabel.text = travel.title
        self.travelDateLabel.text = travel.startDate?.format(endDate: travel.endDate) ?? ""
        if let landmark = travel.landmarks.randomElement() {
            self.travelCardImageView.setImage(with: landmark.image)
        }
        self.travelCardImageView.layer.cornerRadius = 10
        self.travelCardImageView.clipsToBounds = true
    }
}


//
//  TravelCardCell.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import UIKit
import Kingfisher

class TravelCardCell: UICollectionViewCell {
    static let identifier = "TravelCardCell"

    @IBOutlet private weak var travelTitleLabel: UILabel!
    @IBOutlet private weak var travelDateLabel: UILabel!
    @IBOutlet private weak var backgroundButton: UIButton!

    func configure(with travel: Travel) {
        self.travelTitleLabel.text = travel.title
        self.travelDateLabel.text = travel.startDate?.format(endDate: travel.endDate) ?? ""
        if let landmark = travel.landmarks.randomElement() {
            self.backgroundButton.kf.setImage(with: landmark.image, for: .normal)
        }
        self.backgroundButton.layer.cornerRadius = 7
        self.backgroundButton.clipsToBounds = true
    }
}

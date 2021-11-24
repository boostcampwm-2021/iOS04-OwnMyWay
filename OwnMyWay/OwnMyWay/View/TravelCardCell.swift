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
        self.configureAccessibility(with: travel)
    }

    private func configureAccessibility(with travel: Travel) {
        guard let title = travel.title,
              let startDate = travel.startDate,
              let endDate = travel.endDate
        else { return }
        let dateString = startDate == endDate ?
                         "\(startDate.toKorean()) 당일치기" :
                         "\(startDate.toKorean())부터 \(endDate.toKorean())까지"
        self.isAccessibilityElement = true
        self.accessibilityValue = "여행: \(title), \(dateString)"
        self.accessibilityHint = "눌러서 여행 정보를 볼 수 있어요."
    }
}

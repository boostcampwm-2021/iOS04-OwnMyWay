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
    @IBOutlet private weak var backgroundButton: UIButton!

    func configure(travel: Travel) {
        self.travelTitleLabel.text = travel.title
        self.travelDateLabel.text = format(travel: travel)
        self.backgroundButton.layer.cornerRadius = 7
        self.backgroundButton.clipsToBounds = true
    }

    private func format(travel: Travel) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let startDate = travel.startDate,
              let endDate = travel.endDate else {
            return ""
        }
        if startDate == endDate {
            return "\(formatter.string(from: startDate))"
        }
        return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }

}

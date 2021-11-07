//
//  TravelCardCell.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import UIKit

class TravelCardCell: UICollectionViewCell {
    static let identifier = "TravelCardCell"

    @IBOutlet weak var travelTitleLabel: UILabel!
    @IBOutlet weak var backgroundButton: UIButton!

    func configure(travel: Travel) {
        self.travelTitleLabel.text = travel.title
    }

}

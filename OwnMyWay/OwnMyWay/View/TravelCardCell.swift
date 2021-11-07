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

    func setAppearance(travel: Travel) {
        self.travelTitleLabel.text = travel.title
        self.backgroundButton.setBackgroundImage(UIImage(named: "airplane"), for: .normal)
    }

    private func setBackgroundImage(url: URL) {
        guard let imageData = try? Data(contentsOf: url) else {
            return
        }
        backgroundButton.setBackgroundImage(UIImage(data: imageData), for: .normal)
    }

}

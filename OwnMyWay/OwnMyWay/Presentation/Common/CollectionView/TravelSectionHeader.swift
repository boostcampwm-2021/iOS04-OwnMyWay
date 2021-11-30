//
//  TravelSectionHeader.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/07.
//

import UIKit

final class TravelSectionHeader: UICollectionReusableView {
    static let identifier = "TravelSectionHeader"

    @IBOutlet private weak var sectionTitleLabel: UILabel!

    func configure(sectionTitle: String) {
        self.sectionTitleLabel.text = sectionTitle
        self.configureAccessibility(with: sectionTitle)
    }

    func configureAccessibility(with sectionTitle: String) {
        self.isAccessibilityElement = sectionTitle != ""
        self.accessibilityTraits = .header
        self.accessibilityValue = sectionTitle
    }
}

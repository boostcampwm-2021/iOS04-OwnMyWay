//
//  TravelSectionHeader.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/07.
//

import UIKit

class TravelSectionHeader: UICollectionReusableView {
    static let identifier = "TravelSectionHeader"

    @IBOutlet private weak var sectionTitleLabel: UILabel!
    private let fontName = "Apple SD 산돌고딕 Neo"
    private let fontSize: CGFloat = 25

    func configure(sectionTitle: String) {
        let font = UIFont(name: self.fontName, size: self.fontSize)
        self.sectionTitleLabel.font = font ?? UIFont.systemFont(ofSize: self.fontSize)
        self.sectionTitleLabel.text = sectionTitle
    }

}

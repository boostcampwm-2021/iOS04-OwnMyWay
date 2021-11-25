//
//  RecordCardCell.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import UIKit

class RecordCardCell: UICollectionViewCell {

    static let identifier = "RecordCardCell"

    @IBOutlet private weak var recordCardImageView: UIImageView!
    @IBOutlet private weak var recordContentLabel: UILabel!

    func configure(with record: Record) {
        self.makeShadow()
        guard let photos = record.photoURLs else { return }
        self.recordCardImageView.setImage(with: photos.first)
        self.recordContentLabel.text = record.title
        self.configureAccessibility(with: record)
    }

    func configureAccessibility(with record: Record) {
        guard let title = record.title else { return }
        self.isAccessibilityElement = true
        self.accessibilityValue = "기록: \(title)"
        self.accessibilityHint = "눌러서 기록을 자세히 볼 수 있어요."
    }
}

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
    @IBOutlet private weak var recordDesciptionLabel: UILabel!
    
    func configure(with record: Record) {
        self.recordCardImageView.setImage(with: record.photoURL)
        self.recordContentLabel.text = record.content
//        self.recordTimeButton.setTitle(record.date?.time(), for: .normal)
//        self.recordLocationButton.setTitle("루브르", for: .normal)
    }

    func configure(with record: Travel) {
        self.recordCardImageView.setImage(with: record.landmarks.first?.image)
        self.recordContentLabel.text = "I went to the Chumsungdae. It was GREAT!"
        self.recordDesciptionLabel.text = "18:00,\nmusée du Louvre에서"
    }

}

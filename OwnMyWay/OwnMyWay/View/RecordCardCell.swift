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
        self.configureBorderAndShadow()

        //self.recordCardImageView.setImage(with: record.photoURL)
        //self.recordContentLabel.text = record.content

//        self.recordCardImageView.backgroundColor = .green
//        self.recordTimeButton.setTitle(record.date?.time(), for: .normal)
//        self.recordLocationButton.setTitle("루브르", for: .normal)

    }

    func configureBorderAndShadow() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray6.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.systemGray5.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 3
        self.layer.masksToBounds = false
    }

    func configure(with record: Travel) {
        self.recordCardImageView.setImage(with: record.landmarks.first?.image)
        self.recordContentLabel.text = "I went to the Chumsungdae. It was GREAT!"
    }

}

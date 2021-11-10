//
//  DateHeaderView.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/10.
//

import UIKit

class DateHeaderView: UICollectionReusableView {
    static let identifier = "DateHeaderView"

    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with text: String) {
        self.dateLabel.text = text
    }
}

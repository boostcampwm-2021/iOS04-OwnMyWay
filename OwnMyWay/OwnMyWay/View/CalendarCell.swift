//
//  CalendarCell.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/25.
//

import UIKit

class CalendarCell: UICollectionViewCell {

    static let identifier = "CalendarCell"

    @IBOutlet private weak var dateLabel: UILabel!

    func configure(item: CalendarItem) {
        self.dateLabel.text = item.isDummy ? "" : "\(item.date.dayNumber)"
    }
}

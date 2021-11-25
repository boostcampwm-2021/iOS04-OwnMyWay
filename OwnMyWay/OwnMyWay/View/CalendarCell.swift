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
    @IBOutlet private weak var backgroundCellView: UIView!

    func configure(item: CalendarDataSource.CalendarItem) {
        self.dateLabel.text = item.isDummy ? "" : "\(item.date.dayNumber)"
        self.backgroundCellView.backgroundColor = .clear
        self.dateLabel.textColor = .label
    }

    func didSelect() {
        self.backgroundCellView.backgroundColor = UIColor(named: "IdentityBlue") ?? .blue
        self.dateLabel.textColor = .white
    }

}

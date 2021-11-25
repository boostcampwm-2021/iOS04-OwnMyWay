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

    func configure(item: CalendarItem) {
        self.dateLabel.text = item.isDummy ? "" : "\(item.date.dayNumber)"
        self.backgroundCellView.backgroundColor = .clear
        self.dateLabel.textColor = .label
    }

    func didSelect() {
//        UIView.animate(withDuration: 0.20) {
            self.backgroundCellView.backgroundColor = UIColor(named: "IdentityBlue") ?? .blue
            self.dateLabel.textColor = .white
//        }
    }

}

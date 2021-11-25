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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundCellView.layer.cornerRadius = self.backgroundCellView.frame.size.height / 2
    }

    func configure(item: CalendarDataSource.CalendarItem) {
        self.dateLabel.text = item.isDummy ? "" : "\(item.date.dayNumber)"
        let weekday = item.date.weekday
        switch weekday {
        case 1:
            self.dateLabel.textColor = .red
        case 7:
            self.dateLabel.textColor = .blue
        default:
            self.dateLabel.textColor = .label
        }
        if item.date.isToday() && !item.isDummy {
            self.backgroundCellView.backgroundColor = UIColor(named: "WJGreen")
            self.dateLabel.textColor = .white
        } else {
            self.backgroundCellView.backgroundColor = .clear
        }
    }

    func didSelect() {
        self.backgroundCellView.backgroundColor = UIColor(named: "IdentityBlue") ?? .blue
        self.dateLabel.textColor = .white
    }

}

fileprivate extension Date {

    func isToday() -> Bool {
        let today = Date()
        return today.year == self.year &&
        today.month == self.month &&
        today.dayNumber == self.dayNumber
    }

}

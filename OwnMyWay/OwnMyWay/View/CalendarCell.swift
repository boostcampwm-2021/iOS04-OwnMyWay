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
    private let dates = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]

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

        let hint = "\(item.date.dayNumber)일 \(dates[item.date.weekday - 1])입니다. 눌러서 여행 기간을 선택해주세요."
        self.isAccessibilityElement = !item.isDummy
        self.accessibilityHint = hint
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

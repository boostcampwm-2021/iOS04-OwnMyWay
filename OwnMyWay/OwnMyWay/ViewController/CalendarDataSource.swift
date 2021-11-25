//
//  CalendarDataSource.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/25.
//

import UIKit

class CalendarDataSource: NSObject, UICollectionViewDataSource {

    struct CalendarItem: Hashable {
        var isDummy: Bool
        var date: Date
    }

    var date: Date {
        didSet {
            var items = [CalendarItem]()
            for index in 0..<7 - date.firstWeekDayCount {
                items.append(
                    CalendarItem(isDummy: true, date: date.addingTimeInterval(Double(index)))
                )
            }
            for index in 0..<date.numberOfDays {
                items.append(CalendarItem(
                    isDummy: false,
                    date: date.firstDayOfTheMonth.addingTimeInterval(86400 * Double(index))
                ))
            }
            self.items = items
        }
    }
    private var items: [CalendarItem]
    private var startDate: Date?
    private var endDate: Date?

    override init() {
        self.date = Date()
        self.items = []
    }

    func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        return self.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarCell.identifier, for: indexPath
        ) as? CalendarCell
        else { return UICollectionViewCell() }

        let item = self.items[indexPath.item]
        cell.configure(item: item)
        if let startDate = self.startDate,
           let endDate = self.endDate,
           startDate <= item.date && endDate >= item.date,
           !item.isDummy {
            cell.didSelect()
        }
        return cell
    }

    func configureDate(from startDate: Date?, to endDate: Date?) {
        self.startDate = startDate
        self.endDate = endDate
    }

}

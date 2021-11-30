//
//  Date+.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/08.
//

import Foundation

extension Date {
    func localize() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }

    func dotLocalize() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: self)
    }

    func toKorean() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: self)
    }

    func format(endDate: Date?) -> String {
        guard let endDate = endDate,
              self <= endDate else {
            return ""
        }
        if self == endDate {
            return "\(self.localize())"
        }
        return "\(self.localize()) ~ \(endDate.localize())"
    }

    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }

    func dateTime() -> String {
        return self.localize() + " " + self.time()
    }

    // self가 현재로부터 얼만큼 전인지 string으로 알려주는 함수
    func relativeDateTime() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }

}

extension Date {
    var previousMonth: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: self) ?? Date()
    }

    var nextMonth: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self) ?? Date()
    }

    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var dayNumber: Int {
        Calendar.current.component(.day, from: self)
    }

    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    var firstWeekDayCount: Int {
        return 8 - self.firstDayOfTheMonth.weekday
    }

    var numberOfDays: Int {
        let days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        return self.month == 2 ? self.year.isMultiple(of: 4) ? 29 : 28 : days[self.month - 1]
    }

    var firstDayOfTheMonth: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: self)
        ) ?? Date()
    }

}

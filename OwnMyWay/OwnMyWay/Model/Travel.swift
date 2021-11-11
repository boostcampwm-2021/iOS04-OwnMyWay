//
//  Travel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//

import Foundation
import CoreData

struct Travel {

    enum Section: Int, CaseIterable {
        case plusButton = -1
        case reserved = 0
        case ongoing = 1
        case outdated = 2

        var index: Int {
            return self.rawValue
        }
    }

    static func dummy(section: Section) -> Travel {
        return Travel(
            uuid: UUID(), flag: section.index, title: nil,
            startDate: nil, endDate: nil,
            landmarks: [], records: [], locations: []
        )
    }

    var uuid: UUID?
    var flag: Int // 0: 예정된 여행, 1: 진행중인 여행, 2:완료된 여행
    var title: String?
    var startDate: Date?
    var endDate: Date?
    var landmarks: [Landmark]
    var records: [Record]
    var locations: [Location]
}

extension Travel: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

extension Travel {
    func classifyRecords() -> [[Record]] {
        let dict = Dictionary(grouping: self.records) { $0.date?.localize() }.sorted(by: {
            guard let lhs = $0.key, let rhs = $1.key
            else { return true }
            return lhs < rhs
        })
        var array: [[Record]] = []
        dict.forEach { _, value in
            array.append(value.sorted(by: {
                guard let lhs = $0.date, let rhs = $1.date
                else { return true }
                return lhs < rhs
            }))
        }
        return array
    }
}

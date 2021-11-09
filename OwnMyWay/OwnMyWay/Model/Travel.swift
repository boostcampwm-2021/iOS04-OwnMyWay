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
        case reserved = 0
        case ongoing = 1
        case outdated = 2

        var index: Int {
            return self.rawValue
        }
    }

    static func dummy() -> Travel {
        return Travel(
            uuid: UUID(), flag: 0, title: nil,
            startDate: nil, endDate: nil, landmarks: [], records: []
        )
    }

    var uuid: UUID?
    var flag: Int // 0: 예정된 여행, 1: 진행중인 여행, 2:완료된 여행
    var title: String?
    var startDate: Date?
    var endDate: Date?
    var landmarks: [Landmark]
    var records: [Record]
}

extension Travel: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

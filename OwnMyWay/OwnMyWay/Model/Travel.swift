//
//  Travel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//

import Foundation
import CoreData

struct Travel {
    var uuid: UUID?
    var flag: Int // 0: 예정된 여행, 1: 진행중인 여행, 2:완료된 여행
    var title: String?
    var startDate: Date?
    var endDate: Date?
    var landmarks: [Landmark]
    var records: [Record]
    
}

struct Landmark {
    var uuid: UUID?
    var image: URL?
    var latitude: Double?
    var longitude: Double?
    var title: String?
}

struct Record {
    var uuid: UUID?
    var content: String?
    var date: Date?
    var latitude: Double?
    var longitude: Double?
    var photoURL: URL?
}

extension Landmark: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

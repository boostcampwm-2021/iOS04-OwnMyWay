//
//  Record.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//

import Foundation

struct Record {
    var uuid: UUID?
    var title: String?
    var content: String?
    var date: Date?
    var latitude: Double?
    var longitude: Double?
    var photoIDs: [String]?
    var placeDescription: String?

    static func dummy() -> Record {
        return Record(
            uuid: UUID()
        )
    }
}

extension Record: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uuid == rhs.uuid &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.date == rhs.date &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.photoIDs == rhs.photoIDs &&
        lhs.placeDescription == rhs.placeDescription
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        hasher.combine(title)
        hasher.combine(content)
        hasher.combine(date)
        hasher.combine(latitude)
        hasher.combine(longitude)
        hasher.combine(photoIDs)
        hasher.combine(placeDescription)
    }
}

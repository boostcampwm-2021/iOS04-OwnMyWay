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
    var photoURLs: [URL]?
    var placeDescription: String?

    static func dummy() -> Record {
        return Record(
            uuid: UUID()
        )
    }
}

extension Record: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

//
//  Record.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//

import Foundation

struct Record {
    var uuid: UUID?
    var content: String?
    var date: Date?
    var latitude: Double?
    var longitude: Double?
    var photoURL: URL?

    static func dummy() -> Record {
        return Record(
            uuid: UUID(),
            content: nil,
            date: nil,
            latitude: nil,
            longitude: nil,
            photoURL: nil
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
